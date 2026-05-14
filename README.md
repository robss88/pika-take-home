# Pika Take-Home — AI Self Onboarding

A 6-screen SwiftUI onboarding flow: phone sign-in → selfie → voice clone → AI Self ID card.

Built against iOS 26.2, Swift 6 with strict concurrency complete, zero third-party dependencies.

## Running it

1. Open [takehome.xcodeproj](takehome.xcodeproj) in Xcode 26.3 or newer.
2. Pick an iPhone 17 simulator (or any iOS 26.2+ device).
3. ⌘R.

`#if DEBUG` defaults the app to [`AppEnvironment.mock`](takehome/App/AppEnvironment.swift), so every screen works end-to-end without a real backend. Release builds use `.live` against [`APIConfig.live.baseURL`](takehome/Core/Networking/APIConfig.swift) (currently a placeholder).

Tests: ⌘U. 21 Swift Testing tests across `takehomeTests/` covering the API client contract, phone validation, and every ViewModel's happy/failure path.

## Architecture in one breath

- **`@Observable` ViewModels**, one per screen, default-MainActor isolated.
- **Protocol-based DI** via a custom `@Environment(\.app)` value carrying `APIClient`, `AuthService`, `OnboardingClient`, `PhoneNumberFormatter`, plus factories for stateful services (camera, recorder, speech aligner).
- **Typed navigation**: a single `NavigationStack` driven by a `[OnboardingRoute]` path on [`OnboardingCoordinator`](takehome/Features/Onboarding/OnboardingCoordinator.swift). Each route carries forward exactly the data the next step needs — no shared mutable model.
- **Networking**: `URLSession` async/await + typed `Endpoint<Response>` descriptors. `LiveAPIClient` is fully implemented; flipping `AppEnvironment.resolved()` from `.mock` to `.live` is the only switch needed once the backend exists.
- **Strict concurrency complete**: `SWIFT_VERSION = 6`, `SWIFT_STRICT_CONCURRENCY = complete`, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Data types and services that cross actor boundaries are explicitly `nonisolated`.

## Module layout

```
takehome/
├── App/                         takehomeApp, RootView, AppEnvironment
├── Features/Onboarding/
│   ├── OnboardingCoordinator    typed-route NavigationStack source-of-truth
│   ├── OnboardingRoute          camera / voice / success enum
│   ├── SignIn/                  phone field, hero video, ambient audio, OAuth circles
│   ├── Camera/                  AVCaptureSession-backed selfie capture
│   ├── Voice/                   record/listening/review state machine + word-by-word highlight
│   └── Success/                 ID card render, barcode, share sheet, entrance spring
├── Core/
│   ├── Auth/                    AuthService protocol + Live + Mock
│   ├── Networking/              APIClient + Endpoint + LiveAPIClient + MockAPIClient
│   ├── Phone/                   E164 + PhoneNumberFormatter (US impl)
│   ├── Media/                   CameraService, AudioRecorder, looped AudioPlayer
│   └── Speech/                  SpeechAligner protocol + SFSpeechRecognizer live + timed fake
├── DesignSystem/                Color tokens, Font tokens, CapsuleButton, CircleIconButton, ProgressDotsBar, SpringAppear
└── Resources/                   custom fonts; placeholder slots for hero.mp4 + ambient_loop.m4a
```

## Stub-vs-real seam map

| Component | Today | Production swap |
|---|---|---|
| [`APIClient`](takehome/Core/Networking/APIClient.swift) | `MockAPIClient` returns canned per-endpoint responses + records calls for assertions. | `LiveAPIClient` (already shipped) sends real `URLSession` requests. Flip `AppEnvironment.resolved()`. |
| [`AuthService`](takehome/Core/Auth/AuthService.swift) | `MockAuthService` validates E.164 + sleeps 600 ms. | `LiveAuthService` calls `POST /v1/auth/phone` through `APIClient`. |
| [`OnboardingClient`](takehome/Core/Networking/OnboardingClient.swift) | `MockOnboardingClient` echoes the selfie URL as the avatar after 1.2 s. | `LiveOnboardingClient` calls `POST /v1/ai-selves` with the request payload. |
| [`PhoneNumberFormatter`](takehome/Core/Phone/E164.swift) | `USPhoneNumberFormatter` — US-only format-as-you-type + E.164 parse. | Wrap [PhoneNumberKit](https://github.com/marmelroy/PhoneNumberKit) in a conformer for multi-locale support. |
| [`CameraService`](takehome/Core/Media/CameraService.swift) | Real `AVCaptureSession` + `UIViewControllerRepresentable` preview on device. The simulator has no camera hardware, so `AppEnvironment` swaps in [`SimulatorCameraService`](takehome/Core/Media/SimulatorCameraService.swift) that generates a placeholder JPG on shutter — the flow runs end-to-end without a physical device. | Same — production-ready as written. |
| [`AudioRecorder`](takehome/Core/Media/AudioRecorder.swift) | Real `AVAudioRecorder` → m4a in temp dir. | Same. |
| [`SpeechAligner`](takehome/Core/Speech/SpeechAligner.swift) | `LiveSpeechAligner` (on-device `SFSpeechRecognizer`) by default; `FakeTimedSpeechAligner` in `#Preview`. | Trivial swap to `SpeechAnalyzer` (iOS 26+) inside the same protocol seam — see the comment in `LiveSpeechAligner.swift`. |
| Hero video / ambient audio | Looped player wiring is real; falls back to a gradient + silence when `hero.mp4` / `ambient_loop.m4a` are missing from [`Resources/Media/`](takehome/Resources/Media/). | Drop the designer's media in those slots. No code change. |
| Open Messages CTA | Documented no-op (`openMessages` closure on `AppEnvironment`). Logs to console. | Wire to the future Messages module's deep-link. |
| Share ID Card | Real. `ImageRenderer` renders `IDCardView` → PNG → `UIActivityViewController`. | Same. |

## Decisions worth calling out

**Zero third-party dependencies.** The plan originally called for PhoneNumberKit. I chose to roll a 40-line US-only formatter behind a `PhoneNumberFormatter` protocol instead — the senior signal here is "deliberately not adding a dep I didn't need," and the seam means PhoneNumberKit can slot in unchanged when localization arrives.

**`@Observable` over `ObservableObject`.** The 2025+ default; granular property tracking and no `@Published` noise. View models are plain final classes, MainActor-isolated by build default.

**`nonisolated` services + `@MainActor` view models.** With `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, UI types get MainActor for free. Sendable services (`APIClient`, `AuthService`, `OnboardingClient`) are explicitly `nonisolated` so they can be safely shared across tasks.

**Typed routes, payload-passing coordinator.** No shared "OnboardingState" object. Each route enum case carries the data the next step needs (`case voice(phone: E164, selfie: URL)`), so it's impossible to land on the success screen without a captured selfie and voice file.

**On-device speech via `SFSpeechRecognizer`, not `SpeechAnalyzer`.** `SpeechAnalyzer` is iOS 26+ and the longer-term path, but `SFSpeechRecognizer` with `requiresOnDeviceRecognition = true` delivers reliable partial results today across the device + simulator matrix. The protocol seam (`SpeechAligner`) makes a future migration a one-file change.

**Camera + microphone gracefully degrade.** Permission-denied paths surface inline blockers with Open-Settings affordances; missing bundle media on the SignIn screen falls back to a tasteful gradient.

## What I'd revisit with more time

- **Localized phone input.** Country picker + non-US formatter behind the existing `PhoneNumberFormatter` seam (PhoneNumberKit).
- **OTP / SMS verification screen.** Mocks didn't include it; the auth seam is ready.
- **Accessibility pass.** VoiceOver labels on the morphing record button, Dynamic Type for Telka, reduce-motion variants of the success-card entrance.
- **Snapshot tests** of `SignInView`, `IDCardView`, and the `RecordControl` morph states.
- **Telemetry hooks** on the same DI seam (one `Analytics` protocol with `Mock` + `Live`).
- **Background hero asset pipeline** — currently a placeholder slot; a real implementation would prefer streaming a small remote clip with a local fallback.
- **Migrate `LiveSpeechAligner` to `SpeechAnalyzer`** once it stabilizes on real devices.
- **Real-time level metering for the listening pulse** (currently a fixed-cadence pulse — easy to wire to `AVAudioRecorder.averagePower(forChannel:)`).
- **Dark mode polish** — colors are tuned for light. Forced `.light` in the App right now.

## Open questions for the team

### For the designer

- What's the **permission-denied** state for camera, microphone, and speech recognition? I built inline blockers with "Open Settings" — happy to design something more brand-aligned.
- **Non-US phone numbers**: the mock shows the US flag and "+1" only. Country picker scope?
- **Hero video** on SignIn: a looped clip, or a live front-camera preview? Specs (duration, aspect, audio bed)?
- **Script copy**: fixed string or per-locale / personalized?
- **Mis-spoken words during listening** — turn red, or stay un-highlighted gray?
- **ID card photo** is a cropped portrait on Success — should the camera capture be auto-cropped to that aspect, or kept full and cropped at render time?
- **Share ID Card output**: image, vCard, universal link, all three?
- **BPdotsVertical font**: I used it for the barcode strip / accent only. Where else does it belong?
- **Re-record review row**: is the center accept-checkmark intentionally larger than the side buttons (current implementation), or are all three equal-weight?
- **Status field on the card** ("ALIVE") — is this dynamic? What other values exist?

### For the backend

- **AI-self creation endpoint**: sync REST returning the full `IDCard`, or async job + push notification when the avatar is rendered? Latency budget?
- **Selfie + voice upload**: pre-signed S3 URLs, or are we POSTing multipart to `/v1/ai-selves` directly? Max sizes, codecs (m4a/aac OK)?
- **Auth method**: do we expect phone+SMS OTP (and Google/email as separate OAuth flows) or passwordless phone? Rate limits, resend window?
- **`IDCard` fields**: which are server-generated (name, location, find-me URL) vs client-collected (DOB, eye color)?
- **Avatar pipeline**: is the cute 3D-style avatar server-rendered from the selfie + voice, or are we compositing client-side from a model bundle?
- **Auth token shape**: JWT? Refresh token? Where do we persist (Keychain)?
- **Localization + PII handling** for transcribed audio — anything we should know before we send the voice file?

## Testing

`takehomeTests/` (Swift Testing):

| Suite | Covers |
|---|---|
| [`APIClientContractTests`](takehomeTests/APIClientContractTests.swift) | Stubbed responses, unconfigured endpoints, error propagation, cancellation. |
| [`E164ValidationTests`](takehomeTests/E164ValidationTests.swift) | US format-as-you-type + parse rules. |
| [`SignInViewModelTests`](takehomeTests/SignInViewModelTests.swift) | Happy path advances; auth failure surfaces error; invalid phone short-circuits. |
| [`CameraViewModelTests`](takehomeTests/CameraViewModelTests.swift) | Capture happy path; permission denied; capture failure. |
| [`VoiceRecordViewModelTests`](takehomeTests/VoiceRecordViewModelTests.swift) | Idle → listening → review phase walk; recorder failure; re-record reset. |
| [`SuccessViewModelTests`](takehomeTests/SuccessViewModelTests.swift) | Loaded state with canned card; error state when client fails. |

All 21 tests run against the mock services — no network, no microphone, no camera. They double as living documentation of the seam contract.

## Assets

Custom fonts shipped via `INFOPLIST_KEY_UIAppFonts` in [project.pbxproj](takehome.xcodeproj/project.pbxproj):

- **Telka-Extended-Black** — hero display
- **Telka-Extended-Bold** — section titles, ID card name
- **SpaceMono-Regular** / **SpaceMono-Bold** — body + monospaced data
- **BPdotsVertical** — barcode-strip accent / ornament

Hero video + ambient audio are slot-only in [`takehome/Resources/Media/`](takehome/Resources/Media/); the player wiring runs and falls back to a static gradient when the files are absent. Drop in `hero.mp4` and `ambient_loop.m4a` to enable.
