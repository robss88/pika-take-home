import SwiftUI

struct SignInView: View {
    /// Bundled ambient bed for the sign-in hero. Falls back to silence if the
    /// asset is missing — see `AudioPlayer.loop(bundleResource:withExtension:)`.
    private static let ambientResource = (name: "ambient_loop", ext: "m4a")

    @Environment(\.app) private var app
    @State var viewModel: SignInViewModel
    @State private var ambientPlayer: AudioPlayer?

    var body: some View {
        ZStack {
            Color.semiOffWhite.ignoresSafeArea()

            VStack(spacing: 0) {
                hero
                Spacer(minLength: 8)
                form
            }

            if let error = viewModel.error {
                TopErrorBanner(text: error)
            }
        }
        .onAppear {
            let player = app.audioPlayerFactory()
            player.loop(
                bundleResource: Self.ambientResource.name,
                withExtension: Self.ambientResource.ext
            )
            ambientPlayer = player
        }
        .onDisappear {
            ambientPlayer?.stop()
            ambientPlayer = nil
        }
    }

    private var hero: some View {
        HeroVideoView()
            .frame(maxWidth: .infinity)
            .frame(height: 380)
            .mask(
                LinearGradient(
                    colors: [.black, .black, .black, .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .springAppear(distance: 18)
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
            )
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
