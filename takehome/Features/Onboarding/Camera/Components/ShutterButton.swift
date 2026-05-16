import SwiftUI

struct ShutterButton: View {
    let isEnabled: Bool
    let isCapturing: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: Size.primaryAction, height: Size.primaryAction)
                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)  // inner ring — shutter-internal
                    .scaleEffect(isCapturing ? 0.85 : 1.0)
                    .animation(Motion.press, value: isCapturing)
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled || isCapturing ? 1 : 0.4)
    }
}
