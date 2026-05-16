import SwiftUI

struct CircleIconButton: View {
    enum Icon {
        case systemName(String)
        case asset(String)
    }

    let icon: Icon
    var size: CGFloat = 44
    var tint: Color = .semiInk
    var fill: Color = .semiFieldFill
    /// Explicit icon size; nil = proportional to `size` (SF Symbol: 0.42×,
    /// asset: 0.5×).
    var iconSize: CGFloat? = nil
    let action: () -> Void

    init(
        systemName: String,
        size: CGFloat = 44,
        tint: Color = .semiInk,
        fill: Color = .semiFieldFill,
        iconSize: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = .systemName(systemName)
        self.size = size
        self.tint = tint
        self.fill = fill
        self.iconSize = iconSize
        self.action = action
    }

    init(
        assetName: String,
        size: CGFloat = 44,
        tint: Color = .semiInk,
        fill: Color = .semiFieldFill,
        iconSize: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = .asset(assetName)
        self.size = size
        self.tint = tint
        self.fill = fill
        self.iconSize = iconSize
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            iconView
                .frame(width: size, height: size)
                .background(fill, in: .circle)
        }
        .buttonStyle(.plain)
        .contentShape(.circle)
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .systemName(let name):
            Image(systemName: name)
                .font(.system(size: iconSize ?? size * 0.42, weight: .medium))
                .foregroundStyle(tint)
        case .asset(let name):
            // Asset icons default to ~50% of the button so the circle BG
            // reads as breathing room; callers can override with `iconSize`
            // when Figma specifies an exact glyph size (e.g. OAuth at 24pt).
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize ?? size * 0.5, height: iconSize ?? size * 0.5)
        }
    }
}
