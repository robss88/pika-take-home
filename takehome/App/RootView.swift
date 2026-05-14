import SwiftUI

struct RootView: View {
    @Environment(\.app) private var app
    @State private var coordinator = OnboardingCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SignInView(
                viewModel: SignInViewModel(
                    auth: app.auth,
                    phoneFormatter: app.phoneFormatter,
                    onSignedIn: coordinator.didSignIn
                )
            )
            .navigationDestination(for: OnboardingRoute.self) { route in
                routeView(for: route)
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
        .tint(.semiInk)
        .background(Color.semiOffWhite.ignoresSafeArea())
    }

    @ViewBuilder
    private func routeView(for route: OnboardingRoute) -> some View {
        switch route {
        case .camera(let phone):
            CameraView(
                viewModel: CameraViewModel(
                    cameraService: app.cameraServiceFactory(),
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
                    recorder: app.audioRecorderFactory(),
                    aligner: app.speechAlignerFactory(),
                    onAccepted: { voice in
                        coordinator.didRecord(voice: voice, phone: phone, selfie: selfie)
                    },
                    onBack: { coordinator.path.removeLast() }
                )
            )

        case .success(_, let selfie, let voice):
            SuccessView(
                viewModel: SuccessViewModel(
                    client: app.onboarding,
                    selfieURL: selfie,
                    voiceURL: voice,
                    openMessages: app.openMessages,
                    onDismiss: coordinator.reset
                )
            )
        }
    }
}

#Preview("Mock flow") {
    RootView()
        .applyAppEnvironment(.preview)
}
