import SwiftUI

struct SignInView: View {
    @Environment(\.app) private var app
    @State var viewModel: SignInViewModel
    @State private var ambientPlayer = AudioPlayer()
    @FocusState private var phoneFocused: Bool

    var body: some View {
        ZStack {
            Color.semiOffWhite.ignoresSafeArea()

            VStack(spacing: 0) {
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

                Spacer(minLength: 8)

                VStack(spacing: 16) {
                    Text("YOUR AI SELF IS\nWAITING")
                        .multilineTextAlignment(.center)
                        .font(.semiDisplay(32))
                        .foregroundStyle(Color.semiInk)
                        .lineSpacing(2)
                        .minimumScaleFactor(0.7)
                        .springAppear(delay: 0.05)

                    Text("Sign up or log in below")
                        .font(.semiBody(14))
                        .foregroundStyle(Color.semiInk.opacity(0.55))
                        .springAppear(delay: 0.1)

                    phoneField
                        .springAppear(delay: 0.15)

                    CapsuleButton(
                        style: .lavender,
                        isEnabled: viewModel.isValid && !viewModel.isSubmitting,
                        action: {
                            Task { await viewModel.submit() }
                        }
                    ) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.semiInk)
                        } else {
                            Text("Continue")
                        }
                    }
                    .springAppear(delay: 0.2)

                    orContinueWith
                        .springAppear(delay: 0.25)

                    Text("Sign in to agree to \(Text("terms").bold().underline())")
                }
                .multilineTextAlignment(.center)
                .font(.semiBody(13))
                .foregroundStyle(Color.semiInk.opacity(0.7))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }

            if let error = viewModel.error {
                errorBanner(text: error)
            }
        }
        .onAppear {
            ambientPlayer.loop(bundleResource: "ambient_loop", withExtension: "m4a")
        }
        .onDisappear {
            ambientPlayer.stop()
        }
    }

    private var phoneField: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Text("🇺🇸")
                    .font(.system(size: 18))
                Text("+1")
                    .font(.semiMono(14))
                    .foregroundStyle(Color.semiInk.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Color.semiFieldFill.opacity(0.9), in: .capsule)

            TextField(
                "",
                text: Binding(
                    get: { viewModel.phoneText },
                    set: { viewModel.updatePhone($0) }
                ),
                prompt: Text("Phone number").foregroundStyle(Color.semiInk.opacity(0.35))
            )
            .keyboardType(.numberPad)
            .focused($phoneFocused)
            .font(.semiBody(16))
            .foregroundStyle(Color.semiInk)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .padding(.horizontal, 8)
        .frame(height: 56)
        .background(Color.semiFieldFill, in: .capsule)
        .overlay(
            Capsule()
                .strokeBorder(Color.semiInk.opacity(0.04), lineWidth: 1)
        )
    }

    private var orContinueWith: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                line
                Text("Or continue with")
                    .font(.semiBody(11))
                    .foregroundStyle(Color.semiInk.opacity(0.5))
                    .fixedSize(horizontal: true, vertical: false)
                line
            }
            HStack(spacing: 18) {
                CircleIconButton(
                    systemName: "g.circle",
                    size: 52,
                    fill: Color.semiFieldFill,
                    action: { /* OAuth seam */ }
                )
                CircleIconButton(
                    systemName: "envelope",
                    size: 52,
                    fill: Color.semiFieldFill,
                    action: { /* OAuth seam */ }
                )
            }
        }
    }

    private var line: some View {
        Rectangle()
            .fill(Color.semiInk.opacity(0.1))
            .frame(height: 1)
    }

    private func errorBanner(text: String) -> some View {
        VStack {
            Text(text)
                .font(.semiBody(13))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.85), in: .capsule)
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
            Spacer()
        }
    }
}

#Preview {
    SignInView(
        viewModel: SignInViewModel(
            auth: MockAuthService(),
            phoneFormatter: USPhoneNumberFormatter(),
            onSignedIn: { _ in }
        )
    )
    .applyAppEnvironment(.preview)
}
