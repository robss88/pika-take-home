import AVFoundation
import Foundation
import Testing
@testable import takehome

@MainActor
@Suite("CameraViewModel")
struct CameraViewModelTests {
    @Test func capture_happy_path_invokes_onCaptured_and_clears_flash() async {
        let stub = StubCameraService()
        stub.willReturnURL = URL(fileURLWithPath: "/tmp/captured.jpg")

        var captured: URL?
        let vm = CameraViewModel(
            cameraService: stub,
            phone: E164(countryCode: "1", national: "2025550123"),
            onCaptured: { captured = $0 },
            onBack: { }
        )

        await vm.start()
        #expect(vm.phase == .ready)
        await vm.capture()
        #expect(captured?.path == "/tmp/captured.jpg")
        #expect(vm.showFlash == false)
    }

    @Test func permission_denied_surfaces_denied_phase() async {
        let stub = StubCameraService()
        stub.startError = CameraError.permissionDenied

        let vm = CameraViewModel(
            cameraService: stub,
            phone: E164(countryCode: "1", national: "2025550123"),
            onCaptured: { _ in Issue.record("should not capture") },
            onBack: { }
        )

        await vm.start()
        #expect(vm.phase == .denied)
    }

    @Test func capture_failure_does_not_call_onCaptured() async {
        let stub = StubCameraService()
        stub.captureError = CameraError.captureFailed

        let vm = CameraViewModel(
            cameraService: stub,
            phone: E164(countryCode: "1", national: "2025550123"),
            onCaptured: { _ in Issue.record("should not capture") },
            onBack: { }
        )

        await vm.start()
        await vm.capture()
        if case .failed = vm.phase {
            // expected
        } else {
            Issue.record("expected .failed, got \(vm.phase)")
        }
    }

    @Test func back_invokes_callback() {
        var didBack = false
        let vm = CameraViewModel(
            cameraService: StubCameraService(),
            phone: E164(countryCode: "1", national: "2025550123"),
            onCaptured: { _ in },
            onBack: { didBack = true }
        )
        vm.back()
        #expect(didBack)
    }

    @Test func capture_is_noop_unless_phase_is_ready() async {
        let stub = StubCameraService()
        stub.willReturnURL = URL(fileURLWithPath: "/tmp/should-not-fire.jpg")
        let vm = CameraViewModel(
            cameraService: stub,
            phone: E164(countryCode: "1", national: "2025550123"),
            onCaptured: { _ in Issue.record("captured before .ready") },
            onBack: { }
        )
        // Note: vm.start() not called; phase stays .idle.
        await vm.capture()
        #expect(vm.phase == .idle)
    }

    @Test func flip_is_noop_when_not_ready() {
        let stub = StubCameraService()
        let vm = CameraViewModel(
            cameraService: stub,
            phone: E164(countryCode: "1", national: "2025550123"),
            onCaptured: { _ in },
            onBack: { }
        )
        // phase = .idle, flip should not affect the service.
        vm.flip()
        #expect(vm.phase == .idle)
    }
}

// MARK: - Stub camera

@MainActor
private final class StubCameraService: CameraService {
    let previewLayer = AVCaptureVideoPreviewLayer()
    var isRunning: Bool = false
    var startError: Error?
    var captureError: Error?
    var willReturnURL: URL?

    func start() async throws {
        if let startError { throw startError }
        isRunning = true
    }
    func stop() { isRunning = false }
    func flip() {}
    func capturePhoto() async throws -> URL {
        if let captureError { throw captureError }
        return willReturnURL ?? URL(fileURLWithPath: "/tmp/stub.jpg")
    }
}
