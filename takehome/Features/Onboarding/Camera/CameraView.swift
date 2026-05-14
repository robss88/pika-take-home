import SwiftUI

struct CameraView: View {
    @State var viewModel: CameraViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            previewArea
                .ignoresSafeArea()
                .opacity(viewModel.phase == .ready || viewModel.phase == .capturing ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: viewModel.phase)

            if viewModel.showFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            VStack {
                ProgressDotsBar(step: 0, total: 3, onBack: viewModel.back)
                    .padding(.top, 8)
                    .tint(.white)

                Spacer()

                if case .denied = viewModel.phase {
                    permissionBlocker
                } else if case .failed(let msg) = viewModel.phase {
                    failureBlocker(msg)
                }

                cameraControls
                    .padding(.bottom, 32)
            }
        }
        .animation(.easeInOut(duration: 0.12), value: viewModel.showFlash)
        .task { await viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    @ViewBuilder
    private var previewArea: some View {
        #if targetEnvironment(simulator)
        SimulatorPreviewStub()
        #else
        CameraPreview(previewLayer: viewModel.cameraService.previewLayer)
        #endif
    }

    private var cameraControls: some View {
        HStack {
            CircleIconButton(
                systemName: "photo",
                size: 56,
                tint: .white,
                fill: Color.white.opacity(0.18),
                action: { /* Library seam */ }
            )
            Spacer()
            shutterButton
            Spacer()
            CircleIconButton(
                systemName: "arrow.triangle.2.circlepath",
                size: 56,
                tint: .white,
                fill: Color.white.opacity(0.18),
                action: viewModel.flip
            )
        }
        .padding(.horizontal, 32)
    }

    private var shutterButton: some View {
        Button {
            Task { await viewModel.capture() }
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 86, height: 86)
                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)
                    .scaleEffect(viewModel.phase == .capturing ? 0.85 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: viewModel.phase)
            }
        }
        .buttonStyle(.plain)
        .disabled(viewModel.phase != .ready)
        .opacity(viewModel.phase == .ready || viewModel.phase == .capturing ? 1 : 0.4)
    }

    private var permissionBlocker: some View {
        VStack(spacing: 12) {
            Text("Camera access is off")
                .font(.semiTitle(20))
                .foregroundStyle(.white)
            Text("Enable camera access in Settings to capture your selfie.")
                .font(.semiBody(14))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Button("Open Settings") {
                #if canImport(UIKit)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                #endif
            }
            .font(.semiTitle(14))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.semiPurpleDeep, in: .capsule)
        }
        .padding(.bottom, 16)
    }

    private func failureBlocker(_ message: String) -> some View {
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

#if targetEnvironment(simulator)
private struct SimulatorPreviewStub: View {
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

#Preview {
    CameraView(
        viewModel: CameraViewModel(
            cameraService: AVCameraService(),
            phone: E164(countryCode: "1", national: "2025550123"),
            onCaptured: { _ in },
            onBack: { }
        )
    )
    .applyAppEnvironment(.preview)
}
