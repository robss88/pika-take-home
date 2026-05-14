import SwiftUI

/// Two circular auxiliary sign-in buttons (Google + Email). Each action is a
/// closure so the caller can route them through any future OAuth flow.
struct OAuthButtonRow: View {
    let onGoogle: () -> Void
    let onEmail: () -> Void

    var body: some View {
        HStack(spacing: 18) {
            CircleIconButton(
                systemName: "g.circle",
                size: 52,
                fill: Color.semiFieldFill,
                action: onGoogle
            )
            CircleIconButton(
                systemName: "envelope",
                size: 52,
                fill: Color.semiFieldFill,
                action: onEmail
            )
        }
    }
}
