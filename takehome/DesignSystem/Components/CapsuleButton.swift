import SwiftUI

enum CapsuleButtonStyle {
    case lavender      // big primary on SignIn / Voice accept
    case primaryDark   // black pill on Success ("Open Messages")
    case secondaryOffWhite  // warm muted ("Share ID Card")
    case ghost         // outlined / transparent fallback
}

struct CapsuleButton<Label: View>: View {
    let style: CapsuleButtonStyle
    let isEnabled: Bool
    let action: () -> Void
    let label: () -> Label

    init(
        style: CapsuleButtonStyle = .lavender,
        isEnabled: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(action: action) {
            label()
                .font(.semiTitle(17))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(textColor)
                .background(backgroundColor, in: .capsule)
                .opacity(isEnabled ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .contentShape(.capsule)
    }

    private var textColor: Color {
        switch style {
        case .lavender:        return .semiInk
        case .primaryDark:     return .white
        case .secondaryOffWhite: return .semiInk
        case .ghost:           return .semiInk
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .lavender:        return .semiLavender
        case .primaryDark:     return .semiInk
        case .secondaryOffWhite: return .semiCream
        case .ghost:           return .clear
        }
    }
}

extension CapsuleButton where Label == Text {
    init(
        _ title: String,
        style: CapsuleButtonStyle = .lavender,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.init(style: style, isEnabled: isEnabled, action: action) {
            Text(title)
        }
    }
}
