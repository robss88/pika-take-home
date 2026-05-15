import SwiftUI
import UIKit

/// Shown when the user has denied camera access. Surface a clear escape hatch
/// to Settings rather than leaving them stuck on a black screen.
struct CameraPermissionBlocker: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Camera access is off")
                .font(.semiTitle(20))
                .foregroundStyle(.white)
            Text("Enable camera access in Settings to capture your selfie.")
                .font(.semiBody(14))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            Button("Open Settings", action: openSettings)
                .font(.semiTitle(14))
                .foregroundStyle(.white)
                .padding(.horizontal, Spacing.xl - 4)
                .padding(.vertical, Spacing.md - 2)
                .background(Color.semiPurpleDeep, in: .capsule)
        }
        .padding(.bottom, Spacing.lg)
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
