#if targetEnvironment(simulator)
import SwiftUI

/// Stand-in for the live camera preview on the simulator (which has no
/// camera hardware). Used together with `StubCameraService` so the
/// flow stays end-to-end testable without a physical device.
struct SimulatorPreviewStub: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.83, green: 0.80, blue: 0.96),
                    Color(red: 0.97, green: 0.95, blue: 0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                    .foregroundStyle(Color.semiInk.opacity(0.18))
                Text("Simulator preview")
                    .font(.semiMono(11))
                    .foregroundStyle(Color.semiInk.opacity(0.45))
                Text("Tap the shutter — a placeholder selfie will be used.")
                    .font(.semiBody(11))
                    .foregroundStyle(Color.semiInk.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}
#endif
