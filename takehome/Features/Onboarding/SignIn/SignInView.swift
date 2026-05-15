import SwiftUI

struct SignInView: View {
    /// Bottom edge of the visible video (fraction of screen height), aligned
    /// with the top of the "Or continue with" divider.
    private static let videoBottom: Double = 0.80

    @State var viewModel: SignInViewModel
    @FocusState private var phoneFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.semiOffWhite.ignoresSafeArea()
            heroBackground
            form

            if let error = viewModel.error {
                TopErrorBanner(text: error)
            }
        }
        .dismissKeyboardOnTap()
    }

    private var heroBackground: some View {
        HeroVideoView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .black, location: Self.videoBottom),
                        .init(color: .clear, location: Self.videoBottom),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
            .springAppear(distance: 18)
    }

    private var heroFrostedOverlay: some View {
        Rectangle()
            .fill(.thinMaterial)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black, location: 0.2),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea(edges: .bottom)
            .allowsHitTesting(false)
    }

    private var form: some View {
        VStack(spacing: 16) {
            heading.springAppear(delay: 0.05)
            phoneInput.springAppear(delay: 0.15)
            continueButton.springAppear(delay: 0.2)
            AuthDivider(label: "Or continue with").springAppear(delay: 0.25)
            OAuthButtonRow(
                onGoogle: { /* OAuth seam */ },
                onEmail: { /* OAuth seam */ }
            )
            .springAppear(delay: 0.25)
            termsFooter
        }
        .multilineTextAlignment(.center)
        .font(.semiBody(13))
        .foregroundStyle(Color.semiInk.opacity(0.7))
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background { heroFrostedOverlay }
    }

    private var heading: some View {
        VStack(spacing: 12) {
            Text("YOUR AI SELF IS\nWAITING")
                .multilineTextAlignment(.center)
                .font(.semiDisplay(32))
                .foregroundStyle(Color.semiInk)
                .lineSpacing(2)
                .minimumScaleFactor(0.7)
            Text("Sign up or log in below")
                .font(.semiBody(14))
                .foregroundStyle(Color.semiInk.opacity(0.55))
        }
    }

    private var phoneInput: some View {
        PhoneNumberField(
            text: Binding(
                get: { viewModel.phoneText },
                set: { viewModel.updatePhone($0) }
            ),
            focused: $phoneFocused
        )
    }

    @ViewBuilder
    private var continueButton: some View {
        CapsuleButton(
            style: .lavender,
            isEnabled: viewModel.isValid && !viewModel.isSubmitting,
            action: { Task { await viewModel.submit() } }
        ) {
            if viewModel.isSubmitting {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.semiInk)
            } else {
                Text("Continue")
            }
        }
    }

    private var termsFooter: some View {
        HStack(spacing: 4) {
            Text("Sign in to agree to")
            Text("terms").bold().underline()
        }
    }
}

#Preview {
    SignInView(
        viewModel: SignInViewModel(
            auth: AppEnvironment.preview.auth,
            phoneFormatter: AppEnvironment.preview.phoneFormatter,
            onSignedIn: { _ in }
        )
    )
    .applyAppEnvironment(.preview)
}
