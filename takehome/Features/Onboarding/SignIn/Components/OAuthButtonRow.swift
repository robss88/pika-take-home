import SwiftUI

/// Two circular auxiliary sign-in buttons (Google + Email). Each action is a
/// closure so the caller can route them through any future OAuth flow.
struct OAuthButtonRow: View {
    let onGoogle: () -> Void
    let onEmail: () -> Void

    var body: some View {
        HStack(spacing: Spacing.lg) {
            CircleIconButton(
                assetName: "GoogleIcon",
                size: Size.oauthButton,
                fill: Color.surfaceDark6,
                action: onGoogle
            )
            CircleIconButton(
                assetName: "EmailIcon",
                size: Size.oauthButton,
                fill: Color.surfaceDark6,
                action: onEmail
            )
        }
    }
}
