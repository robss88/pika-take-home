import SwiftUI

struct CameraView: View {
    @State var viewModel: CameraViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            preview
                .ignoresSafeArea()
                .opacity(viewModel.phase == .ready || viewModel.phase == .capturing ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: viewModel.phase)

            if viewModel.showFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            VStack {
                TopProgressBar(
                    step: 0,
                    total: 3,
                    tint: .white,
                    track: Color.white.opacity(0.3),
                    arrowColor: .white,
                    onBack: viewModel.back
                )
                .padding(.top, Spacing.sm)

                Spacer()

                blocker

                CameraControls(
                    isReady: viewModel.phase == .ready,
                    isCapturing: viewModel.phase == .capturing,
                    onLibrary: { /* Library seam */ },
                    onShutter: { Task { await viewModel.capture() } },
                    onFlip: viewModel.flip
                )
                .padding(.bottom, Spacing.xxl)
            }
        }
        .animation(.easeInOut(duration: 0.12), value: viewModel.showFlash)
        .task { await viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    @ViewBuilder
    private var preview: some View {
        #if targetEnvironment(simulator)
        SimulatorPreviewStub()
        #else
        CameraPreview(previewLayer: viewModel.cameraService.previewLayer)
        #endif
    }

    @ViewBuilder
    private var blocker: some View {
        switch viewModel.phase {
        case .denied:
            CameraPermissionBlocker()
        case .failed(let message):
            CameraFailureBlocker(message: message)
        default:
            EmptyView()
        }
    }
}

#Preview {
    CameraView(
        viewModel: CameraViewModel(
            cameraService: AppEnvironment.preview.cameraServiceFactory(),
            phone: E164(countryCode: "1", national: "2025550123"),
            onCaptured: { _ in },
            onBack: { }
        )
    )
    .applyAppEnvironment(.preview)
}
