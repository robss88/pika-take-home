import SwiftUI

/// 48×48 rounded back chip. Per Figma: `rgba(13, 13, 13, 0.05)` over a 32pt
/// backdrop blur. SwiftUI doesn't expose blur radius in points; `.thinMaterial`
/// is the closest match for "blurred but still see-through" — what's behind
/// stays legible through the chip.
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
                .background(.thinMaterial, in: .rect(cornerRadius: Radius.lg))
        }
        .buttonStyle(.plain)
        .contentShape(.rect(cornerRadius: Radius.lg))
    }
}
