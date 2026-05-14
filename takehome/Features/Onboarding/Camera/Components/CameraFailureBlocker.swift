import SwiftUI

/// Generic failure surface on the camera screen — capture errors, unavailable
/// hardware, etc. Kept distinct from the permission blocker so the messaging
/// can vary independently.
struct CameraFailureBlocker: View {
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.white)
            Text(message)
                .font(.semiBody(14))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }
}
