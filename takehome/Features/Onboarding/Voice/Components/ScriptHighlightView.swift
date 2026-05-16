import SwiftUI

struct ScriptHighlightView: View {
    let tokens: [ScriptTokenizer.Token]
    let highlightedIndex: Int

    var body: some View {
        WrappingHStack(tokens.indices.map { $0 }, spacing: Spacing.sm, lineSpacing: Spacing.sm) { index in
            Text(tokens[index].display + " ")
                .font(.semiDisplay(28))
                .foregroundStyle(color(for: index))
                .animation(.easeOut(duration: 0.22), value: highlightedIndex)
        }
        .multilineTextAlignment(.center)
    }

    private func color(for index: Int) -> Color {
        index <= highlightedIndex ? .semiPurpleDeep : .semiPurpleSoft
    }
}
