@preconcurrency import AVFoundation
import SwiftUI
import UIKit

@MainActor
protocol CameraService: AnyObject {
    var previewLayer: AVCaptureVideoPreviewLayer { get }
    var isRunning: Bool { get }
    func start() async throws
    func stop()
    func flip()
    func capturePhoto() async throws -> URL
}

enum CameraError: Error, LocalizedError {
    case permissionDenied
    case unavailable
    case captureFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied: return "Camera permission is required to take your selfie."
        case .unavailable: return "No camera is available on this device."
        case .captureFailed: return "Couldn't capture the photo. Please try again."
        }
    }
}

@MainActor
final class AVCameraService: NSObject, CameraService {
    let previewLayer: AVCaptureVideoPreviewLayer
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?
    private var position: AVCaptureDevice.Position = .front
    private var pendingCapture: CheckedContinuation<URL, Error>?

    var isRunning: Bool { session.isRunning }

    override init() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init()
        previewLayer.videoGravity = .resizeAspectFill
    }

    func start() async throws {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            guard granted else { throw CameraError.permissionDenied }
        case .denied, .restricted:
            throw CameraError.permissionDenied
        case .authorized:
            break
        @unknown default:
            throw CameraError.permissionDenied
        }
        try configureSessionIfNeeded()
        if !session.isRunning {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                DispatchQueue.global(qos: .userInitiated).async { [session] in
                    session.startRunning()
                    continuation.resume()
                }
            }
        }
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [session] in
            session.stopRunning()
        }
    }

    func flip() {
        position = (position == .front) ? .back : .front
        do {
            try replaceInput(to: position)
        } catch {
            // Best-effort flip; ignore if the opposite camera is unavailable.
        }
    }

    func capturePhoto() async throws -> URL {
        guard session.isRunning else { throw CameraError.unavailable }
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        return try await withCheckedThrowingContinuation { continuation in
            self.pendingCapture = continuation
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    // MARK: - Session setup

    private func configureSessionIfNeeded() throws {
        guard currentInput == nil else { return }
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        session.sessionPreset = .photo
        try replaceInput(to: position, inExistingConfiguration: true)
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
    }

    private func replaceInput(
        to position: AVCaptureDevice.Position,
        inExistingConfiguration: Bool = false
    ) throws {
        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: position
        ) else { throw CameraError.unavailable }
        if !inExistingConfiguration { session.beginConfiguration() }
        if let currentInput { session.removeInput(currentInput) }
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else { throw CameraError.unavailable }
        session.addInput(input)
        currentInput = input
        if !inExistingConfiguration { session.commitConfiguration() }
    }
}

extension AVCameraService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let data = photo.fileDataRepresentation()
        Task { @MainActor in
            self.handleCapture(data: data, error: error)
        }
    }

    private func handleCapture(data: Data?, error: Error?) {
        guard let continuation = pendingCapture else { return }
        pendingCapture = nil
        if let error {
            continuation.resume(throwing: error)
            return
        }
        guard let data else {
            continuation.resume(throwing: CameraError.captureFailed)
            return
        }
        do {
            let url = FileManager.default
                .temporaryDirectory
                .appendingPathComponent("selfie-\(UUID().uuidString).jpg")
            try data.write(to: url)
            continuation.resume(returning: url)
        } catch {
            continuation.resume(throwing: error)
        }
    }
}
