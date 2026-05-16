import SwiftUI

/// Bundle of services injected through the SwiftUI environment.
///
/// Two factories are shipped:
/// - `.mock` — in-memory test doubles. Default in DEBUG builds and previews.
/// - `.live` — real services backed by `LiveAPIClient`. Default in RELEASE.
///
/// Swapping mock ↔ live is the only flip needed once the backend exists.
/// `LiveAPIClient` is fully implemented against `URLSession`; supply a base URL
/// via `APIConfig.live` and everything compiles unchanged.
struct AppEnvironment: Sendable {
    let api: any APIClient
    let auth: any AuthService
    let onboarding: any OnboardingClient
    let mediaUploader: any MediaUploader
    let phoneFormatter: any PhoneNumberFormatter
    let speechAlignerFactory: @MainActor @Sendable () -> any SpeechAligner
    let cameraServiceFactory: @MainActor @Sendable () -> any CameraService
    let audioRecorderFactory: @MainActor @Sendable () -> any AudioRecorder
    let audioPlayerFactory: @MainActor @Sendable () -> AudioPlayer
    let openMessages: @MainActor @Sendable () -> Void

    static func resolved() -> AppEnvironment {
        #if DEBUG
        return .mock
        #else
        return .live
        #endif
    }

    /// On a real device we hand back a live `AVCameraService`. On the
    /// simulator (which has no camera hardware) we fall back to `StubCameraService`
    /// that generates a placeholder JPG when the shutter fires, so the flow
    /// stays end-to-end testable without a physical device.
    @MainActor
    private static func makeCameraService() -> any CameraService {
        #if targetEnvironment(simulator)
        return StubCameraService()
        #else
        return AVCameraService()
        #endif
    }

    static let live: AppEnvironment = {
        let api = LiveAPIClient(config: .live)
        return AppEnvironment(
            api: api,
            auth: LiveAuthService(api: api),
            onboarding: LiveOnboardingClient(api: api),
            mediaUploader: LiveMediaUploader(api: api),
            phoneFormatter: USPhoneNumberFormatter(),
            speechAlignerFactory: { LiveSpeechAligner() },
            cameraServiceFactory: { Self.makeCameraService() },
            audioRecorderFactory: { AVAudioRecorderService() },
            audioPlayerFactory: { AudioPlayer() },
            openMessages: {
                // Seam: a real Messages module would deep-link here.
                print("[AppEnvironment] openMessages tapped — not yet wired.")
            }
        )
    }()

    static let mock: AppEnvironment = {
        let api = MockAPIClient.preloaded()
        return AppEnvironment(
            api: api,
            auth: MockAuthService(),
            onboarding: MockOnboardingClient(),
            mediaUploader: MockMediaUploader(),
            phoneFormatter: USPhoneNumberFormatter(),
            speechAlignerFactory: { LiveSpeechAligner() },
            cameraServiceFactory: { Self.makeCameraService() },
            audioRecorderFactory: { AVAudioRecorderService() },
            audioPlayerFactory: { AudioPlayer() },
            openMessages: {
                print("[AppEnvironment] openMessages tapped — mock env.")
            }
        )
    }()

    /// Lightweight env for SwiftUI #Preview and tests: everything mocked,
    /// deterministic speech alignment, no real camera / microphone / network
    /// I/O. Audio playback is a no-op `AudioPlayer` that degrades silently
    /// when bundle media is absent.
    static let preview: AppEnvironment = {
        AppEnvironment(
            api: MockAPIClient.preloaded(),
            auth: MockAuthService(),
            onboarding: MockOnboardingClient(),
            mediaUploader: MockMediaUploader(delay: .zero),
            phoneFormatter: USPhoneNumberFormatter(),
            speechAlignerFactory: { FakeTimedSpeechAligner() },
            cameraServiceFactory: { StubCameraService() },
            audioRecorderFactory: { StubAudioRecorder() },
            audioPlayerFactory: { AudioPlayer() },
            openMessages: { }
        )
    }()
}

// MARK: - Environment plumbing

private struct AppEnvironmentKey: EnvironmentKey {
    /// `nil` by design: a RELEASE build that reads `\.app` outside an
    /// `.applyAppEnvironment(_:)` subtree should trap, not silently fall
    /// back to mock data. DEBUG keeps a `.preview` fallback because SwiftUI's
    /// graph-update phase occasionally probes child environments before the
    /// modifier finishes propagating, and trapping there is too noisy.
    static let defaultValue: AppEnvironment? = nil
}

extension EnvironmentValues {
    var app: AppEnvironment {
        get {
            if let env = self[AppEnvironmentKey.self] { return env }
            #if DEBUG
            return .preview
            #else
            fatalError(
                "AppEnvironment not provided. Apply `.applyAppEnvironment(_:)` " +
                "to the view tree (root or preview) before reading `\\.app`."
            )
            #endif
        }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}

extension View {
    func applyAppEnvironment(_ env: AppEnvironment) -> some View {
        environment(\.app, env)
    }
}
