import SwiftUI

struct CircleIconButton: View {
    let systemName: String
    var size: CGFloat = 44
    var tint: Color = .semiInk
    var fill: Color = .semiFieldFill
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: size, height: size)
                .background(fill, in: .circle)
        }
        .buttonStyle(.plain)
        .contentShape(.circle)
    }
}
