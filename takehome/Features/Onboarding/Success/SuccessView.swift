import SwiftUI

struct SuccessView: View {
    @State var viewModel: SuccessViewModel
    @State private var cardAppeared = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.semiOffWhite, Color.semiPurpleSoft.opacity(0.35)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    CircleIconButton(systemName: "xmark", size: 36, action: viewModel.dismiss)
                        .padding(.top, 8)
                        .padding(.trailing, 16)
                }

                Spacer(minLength: 0)

                cardArea

                VStack(spacing: 8) {
                    Text("MEET SEMI")
                        .font(.semiDisplay(38))
                        .foregroundStyle(Color.semiInk)
                    Text("Your AI Self is ready to chat")
                        .font(.semiBody(14))
                        .foregroundStyle(Color.semiInk.opacity(0.6))
                }
                .padding(.top, 24)
                .springAppear(delay: 0.2)

                VStack(spacing: 12) {
                    CapsuleButton(style: .primaryDark, action: viewModel.openMessages) {
                        HStack(spacing: 6) {
                            Text("Open Messages")
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    CapsuleButton(style: .secondaryOffWhite, action: { viewModel.showShare = true }) {
                        HStack(spacing: 6) {
                            Text("Share ID Card")
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 28)
                .springAppear(delay: 0.3)
            }
        }
        .task { await viewModel.load() }
        .sheet(isPresented: $viewModel.showShare) {
            if case .loaded(let card) = viewModel.loadState {
                shareSheet(for: card)
            }
        }
    }

    @ViewBuilder
    private var cardArea: some View {
        switch viewModel.loadState {
        case .loading:
            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.large)
                Text("Building your AI Self…")
                    .font(.semiBody(13))
                    .foregroundStyle(Color.semiInk.opacity(0.6))
            }
            .frame(height: 280)
        case .loaded(let card):
            IDCardView(card: card, localAvatarURL: viewModel.selfieURL)
                .frame(maxWidth: 320)
                .scaleEffect(cardAppeared ? 1 : 0.85)
                .opacity(cardAppeared ? 1 : 0)
                .rotation3DEffect(
                    .degrees(cardAppeared ? 0 : 6),
                    axis: (x: 1, y: 0, z: 0)
                )
                .onAppear {
                    withAnimation(.spring(response: 0.65, dampingFraction: 0.72)) {
                        cardAppeared = true
                    }
                }
        case .error(let msg):
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(Color.semiInk)
                Text(msg)
                    .multilineTextAlignment(.center)
                    .font(.semiBody(13))
                    .foregroundStyle(Color.semiInk.opacity(0.7))
                    .padding(.horizontal, 32)
            }
            .frame(height: 280)
        }
    }

    private func shareSheet(for card: IDCard) -> some View {
        let renderer = ImageRenderer(
            content: IDCardView(card: card, localAvatarURL: viewModel.selfieURL)
                .frame(width: 360)
                .padding(20)
                .background(Color.semiOffWhite)
        )
        renderer.scale = UITraitCollection.current.displayScale
        let items: [Any] = [renderer.uiImage ?? UIImage()]
        return ShareSheet(items: items)
    }
}

#Preview {
    SuccessView(
        viewModel: SuccessViewModel(
            client: MockOnboardingClient(),
            selfieURL: URL(fileURLWithPath: "/tmp/preview-selfie.jpg"),
            voiceURL: URL(fileURLWithPath: "/tmp/preview-voice.m4a"),
            openMessages: { },
            onDismiss: { }
        )
    )
    .applyAppEnvironment(.preview)
}
