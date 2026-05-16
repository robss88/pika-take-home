import SwiftUI

/// Visual style for `CapsuleButton`. Each case maps to a (text, background)
/// color pair; pick by intent at the call site rather than by name —
/// `.lavender` for the primary CTA in a flow, `.primaryDark` for terminal
/// actions, `.secondarySurface` for a quieter dark-surface chip.
enum CapsuleButtonStyle {
    case lavender           // big primary on SignIn / Voice accept
    case primaryDark        // black pill on Success ("Open Messages")
    case secondarySurface   // translucent dark surface chip ("Share ID Card")
}

/// Full-width primary action button. Generic over `Label` so callers can put
/// arbitrary content inside (text, a spinner mid-submit, text + icon). A
/// `Text`-only convenience init is provided below for the common case.
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
                .font(.semiBodyMedium(17))
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .frame(height: Size.controlHeight)
                .foregroundStyle(textColor)
                .background(backgroundColor, in: .rect(cornerRadius: Radius.lg))
                .opacity(isEnabled ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .contentShape(.rect(cornerRadius: Radius.lg))
    }

    private var textColor: Color {
        switch style {
        case .lavender:         return .semiInk
        case .primaryDark:      return .white
        case .secondarySurface: return .semiInk
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .lavender:         return .semiLavender
        case .primaryDark:      return .semiInk
        case .secondarySurface: return .surfaceDark6
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
