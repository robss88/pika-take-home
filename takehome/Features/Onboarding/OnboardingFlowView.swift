import SwiftUI

/// Self-contained shell for the onboarding feature: owns its `NavigationStack`,
/// its coordinator, and its root screen. Adding another feature is a sibling
/// `*FlowView` with its own coordinator and `Route` enum — `AppShell` stays
/// agnostic.
struct OnboardingFlowView: View {
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
                route.destination(.init(env: app, coordinator: coordinator))
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}
