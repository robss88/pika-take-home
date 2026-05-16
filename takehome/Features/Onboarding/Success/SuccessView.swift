import SwiftUI

struct SuccessView: View {
    @State var viewModel: SuccessViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.semiOffWhite, Color.semiBlush],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Spacer(minLength: 0)
                IDCardLoadStateView(
                    state: viewModel.loadState,
                    localAvatarURL: viewModel.selfieURL
                )
                title
                ctas
            }
        }
        .task { await viewModel.load() }
        .sheet(isPresented: $viewModel.showShare) {
            if case .loaded(let card) = viewModel.loadState {
                shareSheet(for: card)
            }
        }
    }

    private var header: some View {
        HStack {
            Spacer()
            CloseButton(action: viewModel.dismiss)
                .padding(.top, Spacing.sm)
                .padding(.trailing, Spacing.lg)
        }
    }

    private var title: some View {
        VStack(spacing: Spacing.sm) {
            Text("MEET SEMI")
                .font(.semiDisplay(38))
                .foregroundStyle(Color.semiInk)
            Text("Your AI Self is ready to chat")
                .font(.semiBody(14))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.top, Spacing.xl)
        .springAppear(delay: 0.2)
    }

    private var ctas: some View {
        VStack(spacing: Spacing.md) {
            CapsuleButton(style: .primaryDark, action: viewModel.openMessages) {
                HStack(spacing: Spacing.xs) {
                    Text("Open Messages")
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            CapsuleButton(style: .secondaryOffWhite, action: { viewModel.showShare = true }) {
                HStack(spacing: Spacing.xs) {
                    Text("Share ID Card")
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.xl + 4)
        .padding(.bottom, Spacing.xl + 4)
        .springAppear(delay: 0.3)
    }

    /// View-level rendering (kept out of the view model on purpose): the
    /// `ImageRenderer` rebuilds the card view tree to snapshot it, which is
    /// SwiftUI presentation, not domain logic. Moving it to the view model
    /// would entangle UIKit (`UIImage`) with the otherwise UI-agnostic VM.
    private func shareSheet(for card: IDCard) -> some View {
        let renderer = ImageRenderer(
            content: IDCardView(card: card, localAvatarURL: viewModel.selfieURL)
                .frame(width: 360)
                .padding(Spacing.lgXl)
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
            client: AppEnvironment.preview.onboarding,
            phone: E164(countryCode: "1", national: "2025550123"),
            selfieURL: URL(fileURLWithPath: "/tmp/preview-selfie.jpg"),
            voiceURL: URL(fileURLWithPath: "/tmp/preview-voice.m4a"),
            openMessages: AppEnvironment.preview.openMessages,
            onDismiss: { }
        )
    )
    .applyAppEnvironment(.preview)
}
