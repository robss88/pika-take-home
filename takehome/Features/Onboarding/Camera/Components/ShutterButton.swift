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
                    .frame(width: 86, height: 86)
                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)
                    .scaleEffect(isCapturing ? 0.85 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isCapturing)
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled || isCapturing ? 1 : 0.4)
    }
}
