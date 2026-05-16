import Foundation
import Observation

@Observable
final class CameraViewModel {
    enum Phase: Equatable {
        case idle
        case starting
        case ready
        case capturing
        case denied
        case failed(String)
    }

    private(set) var phase: Phase = .idle
    var showFlash: Bool = false

    let cameraService: any CameraService
    let phone: E164
    private let onCaptured: (URL) -> Void
    private let onBack: () -> Void

    init(
        cameraService: any CameraService,
        phone: E164,
        onCaptured: @escaping (URL) -> Void,
        onBack: @escaping () -> Void
    ) {
        self.cameraService = cameraService
        self.phone = phone
        self.onCaptured = onCaptured
        self.onBack = onBack
    }

    func start() async {
        guard phase == .idle else { return }
        phase = .starting
        do {
            try await cameraService.start()
            phase = .ready
        } catch CameraError.permissionDenied {
            phase = .denied
        } catch {
            phase = .failed((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    func stop() {
        cameraService.stop()
        // Reset back to `.idle` so `start()` is allowed to re-arm the session
        // when the user navigates back to this screen and wants to retake.
        phase = .idle
        showFlash = false
    }

    func flip() {
        guard phase == .ready else { return }
        cameraService.flip()
    }

    func capture() async {
        guard phase == .ready else { return }
        phase = .capturing
        showFlash = true
        do {
            let url = try await cameraService.capturePhoto()
            // Let the flash animation breathe a beat.
            try? await Task.sleep(for: .milliseconds(120))
            showFlash = false
            onCaptured(url)
        } catch {
            showFlash = false
            phase = .failed((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    func back() { onBack() }
}
