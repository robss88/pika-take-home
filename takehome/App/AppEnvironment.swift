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
    /// simulator (which has no camera hardware) we fall back to a stub that
    /// generates a placeholder JPG when the shutter fires, so the flow
    /// stays end-to-end testable without a physical device.
    @MainActor
    private static func makeCameraService() -> any CameraService {
        #if targetEnvironment(simulator)
        return SimulatorCameraService()
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

    /// Lightweight env for SwiftUI #Preview: everything mocked, deterministic
    /// speech alignment, no camera/audio I/O.
    static let preview: AppEnvironment = {
        AppEnvironment(
            api: MockAPIClient.preloaded(),
            auth: MockAuthService(),
            onboarding: MockOnboardingClient(),
            phoneFormatter: USPhoneNumberFormatter(),
            speechAlignerFactory: { FakeTimedSpeechAligner() },
            cameraServiceFactory: { Self.makeCameraService() },
            audioRecorderFactory: { AVAudioRecorderService() },
            audioPlayerFactory: { AudioPlayer() },
            openMessages: { }
        )
    }()
}

// MARK: - Environment plumbing

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppEnvironment = .preview
}

extension EnvironmentValues {
    var app: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}

extension View {
    func applyAppEnvironment(_ env: AppEnvironment) -> some View {
        environment(\.app, env)
    }
}
