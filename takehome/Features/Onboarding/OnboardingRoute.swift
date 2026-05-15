import SwiftUI

/// Each step's payload carries the data captured at every prior step forward.
/// No shared mutable model — payload through types.
enum OnboardingRoute: Hashable {
    case camera(phone: E164)
    case voice(phone: E164, selfie: URL)
    case success(phone: E164, selfie: URL, voice: URL)
}

extension OnboardingRoute: @MainActor Route {
    struct Context {
        let env: AppEnvironment
        let coordinator: OnboardingCoordinator
    }

    @MainActor @ViewBuilder
    func destination(_ context: Context) -> some View {
        let env = context.env
        let coordinator = context.coordinator
        switch self {
        case .camera(let phone):
            CameraView(
                viewModel: CameraViewModel(
                    cameraService: env.cameraServiceFactory(),
                    phone: phone,
                    onCaptured: { selfie in
                        coordinator.didCapture(selfie: selfie, phone: phone)
                    },
                    onBack: { coordinator.path.removeLast() }
                )
            )

        case .voice(let phone, let selfie):
            VoiceRecordView(
                viewModel: VoiceRecordViewModel(
                    recorder: env.audioRecorderFactory(),
                    aligner: env.speechAlignerFactory(),
                    onAccepted: { voice in
                        coordinator.didRecord(voice: voice, phone: phone, selfie: selfie)
                    },
                    onBack: { coordinator.path.removeLast() }
                )
            )

        case .success(let phone, let selfie, let voice):
            SuccessView(
                viewModel: SuccessViewModel(
                    client: env.onboarding,
                    phone: phone,
                    selfieURL: selfie,
                    voiceURL: voice,
                    openMessages: env.openMessages,
                    onDismiss: coordinator.reset
                )
            )
        }
    }
}
