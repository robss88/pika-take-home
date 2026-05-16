# Pika Take-Home — AI Self Onboarding

A 6-screen SwiftUI onboarding flow: phone sign-in → selfie → voice clone → AI Self ID card.

Built against iOS 26.2, Swift 6 with strict concurrency complete, zero third-party dependencies.

## Running it

1. Open [takehome.xcodeproj](takehome.xcodeproj) in Xcode 26.3 or newer.
2. Pick an iPhone 17 simulator (or any iOS 26.2+ device).
3. ⌘R.

`#if DEBUG` defaults the app to [`AppEnvironment.mock`](takehome/App/AppEnvironment.swift), so every screen works end-to-end without a real backend. Release builds use `.live` against [`APIConfig.live.baseURL`](takehome/Core/Networking/APIConfig.swift) (currently a placeholder).

Tests: ⌘U. 65 Swift Testing cases across `takehomeTests/` cover the API client contract, endpoint construction, phone validation, codable round-trips, the media-upload seam, OAuth path, and every ViewModel's happy/failure path. A single XCUITest smoke (`takehomeUITests/`) confirms the app boots into the sign-in screen.

## Architecture in one breath

- **`@Observable` ViewModels**, one per screen, default-MainActor isolated.
- **Protocol-based DI** via a custom `@Environment(\.app)` value carrying `APIClient`, `AuthService`, `OnboardingClient`, `PhoneNumberFormatter`, plus factories for stateful services (camera, recorder, speech aligner, audio player). The env's `EnvironmentKey` default is `nil`; reading `\.app` outside an `.applyAppEnvironment(_:)` subtree traps in RELEASE so a missing wiring fails loudly instead of silently falling back to mock data.
- **App-level shell + feature-scoped flows.** [`AppShell`](takehome/App/AppShell.swift) is the seam for app-wide concerns (chrome, future auth gate / tab bar / deep-link router) and hosts one feature flow today — [`OnboardingFlowView`](takehome/Features/Onboarding/OnboardingFlowView.swift). Each feature owns its own `NavigationStack`, coordinator, and `Route` enum, so adding a feature is a sibling addition — `AppShell` doesn't grow.
- **Typed navigation via a `Route` protocol** ([`Core/Navigation/Route.swift`](takehome/Core/Navigation/Route.swift)). Each feature's route enum declares its destination view next to the case, with a feature-defined `Context` carrying the dependencies it needs. Each route carries forward exactly the data the next step needs — no shared mutable model.
- **Networking**: `URLSession` async/await + typed `Endpoint<Response>` descriptors. Path strings live in [`APIPaths`](takehome/Core/Networking/APIPaths.swift) so live clients, mock seeds, and tests share one source of truth. `LiveAPIClient` is fully implemented; flipping `AppEnvironment.resolved()` from `.mock` to `.live` is the only switch needed once the backend exists.
- **Strict concurrency complete**: `SWIFT_VERSION = 6`, `SWIFT_STRICT_CONCURRENCY = complete`, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Data types and services that cross actor boundaries are explicitly `nonisolated`.

## Module layout

```
takehome/
├── App/                         takehomeApp, AppShell, AppEnvironment
├── Features/Onboarding/
│   ├── OnboardingFlowView       feature shell: NavigationStack + coordinator + sign-in root
│   ├── OnboardingCoordinator    typed-route navigation source-of-truth
│   ├── OnboardingRoute          camera / voice / success enum + Route conformance
│   ├── SignIn/                  phone field, hero video (looped + audio), OAuth circles
│   ├── Camera/                  AVCaptureSession-backed selfie capture
│   ├── Voice/                   record/listening/review state machine + word-by-word highlight
│   └── Success/                 ID card render, barcode, share sheet, entrance spring
├── Core/
│   ├── Auth/                    AuthService protocol + Live + Mock
│   ├── Navigation/              feature-agnostic Route protocol
│   ├── Networking/              APIClient + Endpoint + Live/MockAPIClient + APIPaths + MediaUploader
│   ├── Phone/                   E164 + PhoneNumberFormatter (US impl)
│   ├── Media/                   CameraService (live + stub), AudioRecorder (live + stub), AudioPlayer
│   └── Speech/                  SpeechAligner protocol + SFSpeechRecognizer live + timed fake
├── DesignSystem/                Color / Font / Spacing / Size / Radius tokens,
│                                CapsuleButton, CircleIconButton, BackButton,
│                                TopProgressBar, TopErrorBanner, ShareSheet,
│                                Layout/WrappingHStack, Modifiers/SpringAppear,
│                                Modifiers/DismissKeyboardOnTap
└── Resources/                   custom fonts; hero.mp4 in Resources/Media (audio carried on the clip)
```

## Stub-vs-real seam map

| Component | Today | Production swap |
|---|---|---|
| [`APIClient`](takehome/Core/Networking/APIClient.swift) | `MockAPIClient` returns canned per-endpoint responses + records calls for assertions. | `LiveAPIClient` (already shipped) sends real `URLSession` requests. Flip `AppEnvironment.resolved()`. |
| [`AuthService`](takehome/Core/Auth/AuthService.swift) | `MockAuthService` validates E.164 + sleeps 600 ms. | `LiveAuthService` calls `POST /v1/auth/phone` through `APIClient`. |
| [`OnboardingClient`](takehome/Core/Networking/OnboardingClient.swift) | `MockOnboardingClient` echoes the selfie URL as the avatar after 1.2 s. | `LiveOnboardingClient` calls `POST /v1/ai-selves` with the request payload. |
| [`MediaUploader`](takehome/Core/Networking/MediaUploader.swift) | `MockMediaUploader` waits 450 ms and returns a synthesized `voice/<uuid>.key` or `selfie/<uuid>.key`. | `LiveMediaUploader` will multipart-POST the file (today echoes the path so the rest of the flow stays typed). Comment marks the eventual `/v1/uploads` endpoint. |
| [`PhoneNumberFormatter`](takehome/Core/Phone/E164.swift) | `USPhoneNumberFormatter` — US-only format-as-you-type + E.164 parse. | Wrap [PhoneNumberKit](https://github.com/marmelroy/PhoneNumberKit) in a conformer for multi-locale support. |
| [`CameraService`](takehome/Core/Media/CameraService.swift) | Real `AVCaptureSession` + `UIViewControllerRepresentable` preview on device. The simulator has no camera hardware and previews/tests shouldn't touch real I/O, so `AppEnvironment` hands `.preview` (and the simulator branch of `.mock`) a [`StubCameraService`](takehome/Core/Media/StubCameraService.swift) that renders a placeholder JPG on shutter. | Same — production-ready as written. |
| [`AudioRecorder`](takehome/Core/Media/AudioRecorder.swift) | Real `AVAudioRecorder` → m4a in temp dir. `.preview` swaps in [`StubAudioRecorder`](takehome/Core/Media/StubAudioRecorder.swift) so SwiftUI `#Preview` exercises the voice flow without microphone access. | Same. |
| [`SpeechAligner`](takehome/Core/Speech/SpeechAligner.swift) | `LiveSpeechAligner` (on-device `SFSpeechRecognizer`) by default; `FakeTimedSpeechAligner` in `#Preview`. | Trivial swap to `SpeechAnalyzer` (iOS 26+) inside the same protocol seam — see the comment in `LiveSpeechAligner.swift`. |
| Hero video | `AVPlayerLooper` plays `hero.mp4` from [`Resources/Media/`](takehome/Resources/Media/), carrying its own audio bed (`.ambient` category, mixes with other apps and respects the silent switch). Pauses on screen disappear; falls back to a tasteful gradient if the file is missing. | Same — production-ready. |
| Open Messages CTA | Documented no-op (`openMessages` closure on `AppEnvironment`). Logs to console. | Wire to the future Messages module's deep-link. |
| Share ID Card | Real. `ImageRenderer` renders `IDCardView` → PNG → `UIActivityViewController`. | Same. |

## Decisions worth calling out

**Zero third-party dependencies.** The plan originally called for PhoneNumberKit. I chose to roll a 40-line US-only formatter behind a `PhoneNumberFormatter` protocol instead — the senior signal here is "deliberately not adding a dep I didn't need," and the seam means PhoneNumberKit can slot in unchanged when localization arrives.

**`@Observable` over `ObservableObject`.** The 2025+ default; granular property tracking and no `@Published` noise. View models are plain final classes, MainActor-isolated by build default.

**`nonisolated` services + `@MainActor` view models.** With `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, UI types get MainActor for free. Sendable services (`APIClient`, `AuthService`, `OnboardingClient`) are explicitly `nonisolated` so they can be safely shared across tasks.

**Feature-scoped navigation shells with a `Route` protocol.** `AppShell` is the app-level seam (chrome + which feature is active), and every feature owns its own `*FlowView` with its own `NavigationStack`, coordinator, and `Route` enum. The [`Route`](takehome/Core/Navigation/Route.swift) protocol lets each route declare its destination view next to the case, with a feature-defined `Context`, so the destination switch never lives in `AppShell` and a 100-screen app doesn't grow a god-function.

**Typed routes, payload-passing coordinator.** No shared "OnboardingState" object. Each route enum case carries the data the next step needs (`case voice(phone: E164, selfie: URL)`), so it's impossible to land on the success screen without a captured selfie and voice file.

**Hardened `AppEnvironment` default.** The `EnvironmentKey` default is `nil`. Reading `\.app` outside an `.applyAppEnvironment(_:)` subtree traps in RELEASE so a missing wiring fails loudly. DEBUG keeps a `.preview` fallback because SwiftUI's graph-update phase occasionally probes child environments before the modifier finishes propagating, and trapping there is too noisy for day-to-day work.

**Dual-state `PhoneNumberField`.** The field owns a local `@State String` shadowing the caller's `@Binding`, with two `onChange` handlers shuttling between them. The footgun this works around: SwiftUI's `TextField` doesn't reliably re-render mid-edit when a `Binding(get:set:)` wrapper mutates the bound value — which is exactly what a format-as-you-type setter does. Without the local state, the parens never appear on screen as the user types. The dual-state pattern is isolated to this one field so the cost stays local. See [`PhoneNumberField.swift`](takehome/Features/Onboarding/SignIn/Components/PhoneNumberField.swift).

**OAuth → placeholder `E164`.** `SignInViewModel.oauth(_:)` synthesizes `E164(countryCode: "1", national: "0000000000")` and threads it through `onSignedIn`. The typed route payload requires an `E164`, OAuth doesn't return a phone today, and adding a follow-up "collect phone" screen is the right backend coordination ask — flagged in "Open questions for the backend" below. The placeholder is a deliberate seam, not a missing check.

**Design-system tokens for every layout dimension.** Spacing, sizing, radius, color, and font scales live in [`DesignSystem/`](takehome/DesignSystem/). The rule: a literal earns a token when it (a) repeats across ≥2 files or (b) captures a shared semantic concept ("screen edge", "control height"). Component-internal morph constants (RecordControl's pulse ring, ShutterButton's inner ring) stay private to the component so they don't pollute the shared namespace.

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
- **Re-record review row**: is the center accept-checkmark intentionally larger than the side buttons (current implementation), or are all three equal-weight?
- **Status field on the card** ("ALIVE") — is this dynamic? What other values exist?

### For the backend

- **AI-self creation endpoint**: sync REST returning the full `IDCard`, or async job + push notification when the avatar is rendered? Latency budget?
- **Media upload contract**: the `MediaUploader` seam expects a "key" back. Is that a presigned S3 URL the client uploads to directly, a multipart POST to a dedicated `/v1/uploads`, or bundled into `/v1/ai-selves`? Max sizes, codecs (m4a/aac OK)?
- **OAuth → phone**: does Google/email auth return a phone-on-file from your side, or should the client present a follow-up "collect phone" screen after successful OAuth? Today the client synthesizes a placeholder `+10000000000` to advance — a real backend signal would drop that hack.
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
| [`APIErrorTests`](takehomeTests/APIErrorTests.swift) | `APIError` `LocalizedError` descriptions for each case. |
| [`EndpointBuilderTests`](takehomeTests/EndpointBuilderTests.swift) | `Endpoint.json` body encoding, method/path round-trip, decode failure. |
| [`IDCardCodableTests`](takehomeTests/IDCardCodableTests.swift) | `IDCard.canned` round-trips through the shared snake-case encoder. |
| [`LiveServiceTests`](takehomeTests/LiveServiceTests.swift) | Live auth + onboarding clients post to the right `APIPaths`. |
| [`E164ValidationTests`](takehomeTests/E164ValidationTests.swift) | US format-as-you-type + parse rules. |
| [`ScriptTokenizerTests`](takehomeTests/ScriptTokenizerTests.swift) | Token boundaries / empty input edge cases for the voice script. |
| [`OnboardingCoordinatorTests`](takehomeTests/OnboardingCoordinatorTests.swift) | Route payload threading, reset, hashable distinctness. |
| [`SignInViewModelTests`](takehomeTests/SignInViewModelTests.swift) | Phone happy path; auth failure surfaces error; invalid phone short-circuits; OAuth (Google/email) advances with placeholder phone + propagates failure. |
| [`MediaUploaderTests`](takehomeTests/MediaUploaderTests.swift) | Mock upload returns `voice/`- or `selfie/`-prefixed keys; failure-injected upload throws. |
| [`CameraViewModelTests`](takehomeTests/CameraViewModelTests.swift) | Capture happy path; permission denied; capture failure. |
| [`VoiceRecordViewModelTests`](takehomeTests/VoiceRecordViewModelTests.swift) | Idle → listening → review phase walk; recorder failure; re-record reset. |
| [`SuccessViewModelTests`](takehomeTests/SuccessViewModelTests.swift) | Loaded state with canned card; error state when client fails; phone threaded into the API request. |

All 65 tests run against the mock services — no network, no microphone, no camera. They double as living documentation of the seam contract. The lone XCUITest in [`takehomeUITests/`](takehomeUITests/takehomeUITests.swift) launches the host app and asserts the sign-in hero is reachable.

## Assets

Custom fonts registered at launch by [`FontRegistration`](takehome/App/FontRegistration.swift) (scans `Resources/Fonts/` so adding a font is drop-in):

- **Telka-Extended-Black** — hero display
- **Telka-Extended-Bold** — section titles, ID card name, button labels
- **Telka-Extended-Medium** — sub-display weight (currently reserved)
- **Telka-Regular** / **Telka-Medium** — body copy + primary button labels
- **SpaceMono-Regular** / **SpaceMono-Bold** — country code, ID-card tabular data

`Image` assets live in `takehome/Assets.xcassets/`: `GoogleIcon`, `EmailIcon` (OAuth circles), `RabbitIcon` (ID card emblem — template-rendered, picks up the foreground tint).

[`takehome/Resources/Media/`](takehome/Resources/Media/) holds `hero.mp4` (looped sign-in clip, carrying its own audio bed). The player gracefully falls back to a soft radial gradient if the file is missing — useful for previews and the first-pass build before the designer ships final media.
