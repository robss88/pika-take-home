import SwiftUI

/// Word-by-word highlighter for the voice script. Renders `tokens` in a
/// centered flow layout; every token at index `≤ highlightedIndex` is drawn
/// in the deep brand purple, the rest in the soft lavender. The view itself
/// is stateless — `highlightedIndex` is driven by the `SpeechAligner` stream
/// in `VoiceRecordViewModel`.
struct ScriptHighlightView: View {
    let tokens: [ScriptTokenizer.Token]
    let highlightedIndex: Int

    var body: some View {
        WrappingHStack(tokens.indices.map { $0 }, spacing: Spacing.sm, lineSpacing: Spacing.sm) { index in
            Text(tokens[index].display + " ")
                .font(.semiDisplay(28))
                .foregroundStyle(color(for: index))
                .animation(Motion.highlight, value: highlightedIndex)
        }
        .multilineTextAlignment(.center)
    }

    private func color(for index: Int) -> Color {
        index <= highlightedIndex ? .semiPurpleDeep : .semiPurpleSoft
    }
}
