import SwiftUI

/// Rounded-rect dismiss chip — sibling to `BackButton` but visually quieter
/// (transparent fill + 1pt hairline border) because dismissing is a less
/// primary action than going back through a navigation flow.
struct CloseButton: View {
    var tint: Color = .semiInk
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: Size.backButton, height: Size.backButton)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .stroke(Color.semiInk.opacity(0.12), lineWidth: Size.hairline)
                )
        }
        .buttonStyle(.plain)
        .contentShape(.rect(cornerRadius: Radius.lg))
    }
}
