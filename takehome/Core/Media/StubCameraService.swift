@preconcurrency import AVFoundation
import SwiftUI
import UIKit

/// I/O-free stand-in for `AVCameraService`. Used wherever a real
/// `AVCaptureSession` is unavailable or unwanted: the iOS simulator (no
/// camera hardware), SwiftUI `#Preview`, and tests. The shutter renders a
/// placeholder JPG to the temp dir so the rest of the flow exercises
/// end-to-end without a physical device.
@MainActor
final class StubCameraService: CameraService {
    let previewLayer = AVCaptureVideoPreviewLayer()
    private(set) var isRunning: Bool = false
    private var faceUp: Bool = true

    func start() async throws {
        isRunning = true
    }
    func stop() { isRunning = false }
    func flip() { faceUp.toggle() }

    func capturePhoto() async throws -> URL {
        let size = CGSize(width: 900, height: 1200)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 0.83, green: 0.80, blue: 0.96, alpha: 1).cgColor,
                    UIColor(red: 0.97, green: 0.95, blue: 0.92, alpha: 1).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
            let icon = UIImage(systemName: "person.crop.circle.fill")?
                .withTintColor(UIColor(white: 0.08, alpha: 0.25), renderingMode: .alwaysOriginal)
            icon?.draw(in: rect.insetBy(dx: size.width * 0.18, dy: size.height * 0.18))
        }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("stub-selfie-\(UUID().uuidString).jpg")
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw CameraError.captureFailed
        }
        try data.write(to: url)
        try? await Task.sleep(for: .milliseconds(150))
        return url
    }
}
