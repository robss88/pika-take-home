#if targetEnvironment(simulator)
import SwiftUI

/// Stand-in for the live camera preview on the simulator (which has no
/// camera hardware). Used together with `StubCameraService` so the
/// flow stays end-to-end testable without a physical device.
struct SimulatorPreviewStub: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.semiPurpleSoft, Color.semiOffWhite],
                startPoint: .top,
                endPoint: .bottom
            )
            VStack(spacing: Spacing.md) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)   // stub illustration size, one-off
                    .foregroundStyle(Color.semiInk.opacity(0.18))
                Text("Simulator preview")
                    .font(.semiMono(11))
                    .foregroundStyle(Color.semiInk.opacity(0.45))
                Text("Tap the shutter — a placeholder selfie will be used.")
                    .font(.semiBody(11))
                    .foregroundStyle(Color.semiInk.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxl + Spacing.sm)
            }
        }
    }
}
#endif
