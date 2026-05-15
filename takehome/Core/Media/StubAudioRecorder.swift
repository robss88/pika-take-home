import Foundation

/// I/O-free stand-in for `AVAudioRecorderService`. No AVFoundation session,
/// no microphone access, no file on disk beyond a zero-byte placeholder.
/// Used by `AppEnvironment.preview` so SwiftUI `#Preview` and tests can drive
/// the voice flow without touching real hardware.
@MainActor
final class StubAudioRecorder: AudioRecorder {
    private(set) var isRecording: Bool = false
    private var currentURL: URL?

    func requestPermission() async -> Bool { true }

    func start() async throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("stub-voice-\(UUID().uuidString).m4a")
        try Data().write(to: url)
        isRecording = true
        currentURL = url
        return url
    }

    func stop() async -> URL? {
        isRecording = false
        let url = currentURL
        currentURL = nil
        return url
    }

    func cancel() {
        if let url = currentURL { try? FileManager.default.removeItem(at: url) }
        isRecording = false
        currentURL = nil
    }
}
