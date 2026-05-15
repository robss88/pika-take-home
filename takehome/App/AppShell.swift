import SwiftUI

/// App-level seam: chooses which feature flow is currently active and applies
/// app-wide chrome (tint, background). This is the single place to add
/// concerns that span every feature — auth gating, tab/shell once signed in,
/// app-level modals, deep-link routing — so neither `takehomeApp` (the
/// `@main` entry) nor individual `*FlowView`s have to grow them.
struct AppShell: View {
    var body: some View {
        OnboardingFlowView()
            .tint(.semiInk)
            .background(Color.semiOffWhite.ignoresSafeArea())
    }
}

#Preview("Mock flow") {
    AppShell()
        .applyAppEnvironment(.preview)
}
