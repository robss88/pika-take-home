import AVFoundation
import Foundation

@MainActor
protocol AudioRecorder: AnyObject {
    var isRecording: Bool { get }
    func requestPermission() async -> Bool
    func start() async throws -> URL
    func stop() async -> URL?
    func cancel()
}

enum AudioRecorderError: Error, LocalizedError {
    case permissionDenied
    case sessionFailed(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied: return "Microphone permission is required to record your voice."
        case .sessionFailed(let detail): return "Couldn't start recording: \(detail)"
        }
    }
}

@MainActor
final class AVAudioRecorderService: NSObject, AudioRecorder {
    private var recorder: AVAudioRecorder?
    private var currentURL: URL?

    var isRecording: Bool { recorder?.isRecording == true }

    func requestPermission() async -> Bool {
        if #available(iOS 17, *) {
            return await AVAudioApplication.requestRecordPermission()
        } else {
            return await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    cont.resume(returning: granted)
                }
            }
        }
    }

    func start() async throws -> URL {
        let granted = await requestPermission()
        guard granted else { throw AudioRecorderError.permissionDenied }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true, options: [])
        } catch {
            throw AudioRecorderError.sessionFailed(error.localizedDescription)
        }

        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("voice-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            let r = try AVAudioRecorder(url: url, settings: settings)
            r.isMeteringEnabled = true
            guard r.record() else {
                throw AudioRecorderError.sessionFailed("recorder refused to start")
            }
            self.recorder = r
            self.currentURL = url
            return url
        } catch let err as AudioRecorderError {
            throw err
        } catch {
            throw AudioRecorderError.sessionFailed(error.localizedDescription)
        }
    }

    func stop() async -> URL? {
        guard let r = recorder else { return nil }
        r.stop()
        let url = currentURL
        recorder = nil
        return url
    }

    func cancel() {
        recorder?.stop()
        if let url = currentURL { try? FileManager.default.removeItem(at: url) }
        recorder = nil
        currentURL = nil
    }
}
