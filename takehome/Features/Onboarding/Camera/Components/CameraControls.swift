import SwiftUI

/// Bottom control row for the camera screen: library, shutter, flip.
struct CameraControls: View {
    let isReady: Bool
    let isCapturing: Bool
    let onLibrary: () -> Void
    let onShutter: () -> Void
    let onFlip: () -> Void

    var body: some View {
        HStack {
            CircleIconButton(
                systemName: "photo",
                size: 56,
                tint: .white,
                fill: Color.white.opacity(0.18),
                action: onLibrary
            )
            Spacer()
            ShutterButton(
                isEnabled: isReady,
                isCapturing: isCapturing,
                action: onShutter
            )
            Spacer()
            CircleIconButton(
                systemName: "arrow.triangle.2.circlepath",
                size: 56,
                tint: .white,
                fill: Color.white.opacity(0.18),
                action: onFlip
            )
        }
        .padding(.horizontal, 32)
    }
}
