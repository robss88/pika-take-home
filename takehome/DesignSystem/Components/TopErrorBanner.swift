import SwiftUI

/// Top-anchored transient error banner. Suitable for short, recoverable errors
/// like a failed sign-in attempt; not for blocking-state messaging.
struct TopErrorBanner: View {
    let text: String

    var body: some View {
        VStack {
            Text(text)
                .font(.semiBody(13))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.85), in: .capsule)
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
            Spacer()
        }
    }
}
