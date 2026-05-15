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
    let action: () -> Void

    init(
        systemName: String,
        size: CGFloat = 44,
        tint: Color = .semiInk,
        fill: Color = .semiFieldFill,
        action: @escaping () -> Void
    ) {
        self.icon = .systemName(systemName)
        self.size = size
        self.tint = tint
        self.fill = fill
        self.action = action
    }

    init(
        assetName: String,
        size: CGFloat = 44,
        tint: Color = .semiInk,
        fill: Color = .semiFieldFill,
        action: @escaping () -> Void
    ) {
        self.icon = .asset(assetName)
        self.size = size
        self.tint = tint
        self.fill = fill
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
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundStyle(tint)
        case .asset(let name):
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
}
