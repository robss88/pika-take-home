import SwiftUI

/// Renders the three states of the AI-self creation flow:
/// `.loading` → spinner, `.loaded(IDCard)` → the card with entrance animation,
/// `.error(String)` → a friendly inline failure surface.
struct IDCardLoadStateView: View {
    let state: SuccessViewModel.LoadState
    let localAvatarURL: URL
    @State private var cardAppeared = false

    var body: some View {
        switch state {
        case .loading:
            loadingView
        case .loaded(let card):
            loadedView(card: card)
        case .error(let message):
            errorView(message: message)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
            Text("Building your AI Self…")
                .font(.semiBody(13))
                .foregroundStyle(Color.semiInk.opacity(0.6))
        }
        .frame(height: 280)
    }

    private func loadedView(card: IDCard) -> some View {
        IDCardView(card: card, localAvatarURL: localAvatarURL)
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
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(Color.semiInk)
            Text(message)
                .multilineTextAlignment(.center)
                .font(.semiBody(13))
                .foregroundStyle(Color.semiInk.opacity(0.7))
                .padding(.horizontal, 32)
        }
        .frame(height: 280)
    }
}
