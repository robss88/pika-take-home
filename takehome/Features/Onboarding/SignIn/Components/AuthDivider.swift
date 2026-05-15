import SwiftUI

/// "Or continue with" divider used between the primary CTA and OAuth buttons.
struct AuthDivider: View {
    let label: String

    var body: some View {
        HStack(spacing: 12) {
            line
            Text(label)
                .font(.semiBodyMedium(12))
                .foregroundStyle(Color.semiInk.opacity(0.5))
                .fixedSize(horizontal: true, vertical: false)
            line
        }
    }

    private var line: some View {
        Rectangle()
            .fill(Color.semiInk.opacity(0.1))
            .frame(height: 1)
    }
}
