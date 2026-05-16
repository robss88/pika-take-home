import SwiftUI

/// 48×48 rounded back chip with a frosted backdrop. Per Figma:
/// `rgba(13, 13, 13, 0.05)` on top of a 32pt backdrop blur. SwiftUI doesn't
/// expose blur radius in points, so we map the 32pt Figma blur to
/// `.regularMaterial` — noticeable softening on a dark backdrop (camera),
/// gentle frost on light ones (voice / success).
struct BackButton: View {
    var arrowColor: Color = .semiInk
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(arrowColor)
                .frame(width: Size.backButton, height: Size.backButton)
                .background(Color.surfaceDark6, in: .rect(cornerRadius: Radius.lg))
                .background(.regularMaterial, in: .rect(cornerRadius: Radius.lg))
        }
        .buttonStyle(.plain)
        .contentShape(.rect(cornerRadius: Radius.lg))
    }
}
