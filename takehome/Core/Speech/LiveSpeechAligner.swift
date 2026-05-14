@preconcurrency import AVFoundation
import Foundation
import os
import Speech

/// Live alignment using `SFSpeechRecognizer` on-device.
///
/// We keep a monotonic pointer over the script's normalized tokens and walk it
/// forward whenever the recognizer's latest transcription contains the next
/// expected token (with a small look-ahead to tolerate misrecognitions).
///
/// Why `SFSpeechRecognizer` and not iOS 26's new `SpeechAnalyzer`: as of the
/// time of writing, `SpeechAnalyzer` is the future surface, but `SFSpeech-
/// Recognizer` is still the most reliable on-device option across the current
/// simulator + device matrix, with sub-second partial results that are good
/// enough for the read-along highlight. The protocol seam (`SpeechAligner`)
/// makes the swap a one-file change if we want to migrate later.
@MainActor
final class LiveSpeechAligner: NSObject, SpeechAligner {
    private let recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    override init() {
        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        super.init()
    }

    func align(script: [ScriptTokenizer.Token]) -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream { continuation in
            Task { @MainActor in
                do {
                    try await self.bootAndStream(script: script, continuation: continuation)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor in self?.cancel() }
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
        request?.endAudio()
        request = nil
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
    }

    // MARK: - Internals

    private func bootAndStream(
        script: [ScriptTokenizer.Token],
        continuation: AsyncThrowingStream<Int, Error>.Continuation
    ) async throws {
        let authorized = await Self.requestAuthorization()
        guard authorized else { throw SpeechAlignerError.permissionDenied }
        guard let recognizer, recognizer.isAvailable else {
            throw SpeechAlignerError.unavailable
        }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: [.notifyOthersOnDeactivation])
        } catch {
            throw SpeechAlignerError.engineFailed(error.localizedDescription)
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = true
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // Audio tap runs on AVAudio's realtime thread — must be @Sendable
        // (i.e. nonisolated). It captures only the recognition request, whose
        // `append(_:)` is documented thread-safe; `SFSpeechAudioBuffer-
        // RecognitionRequest` isn't marked `Sendable` in Apple's headers, so
        // we bridge it explicitly here.
        nonisolated(unsafe) let appendRequest = request
        let appendBuffer: @Sendable (AVAudioPCMBuffer, AVAudioTime) -> Void = { buffer, _ in
            appendRequest.append(buffer)
        }
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format, block: appendBuffer)

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            throw SpeechAlignerError.engineFailed(error.localizedDescription)
        }

        // Cross-thread state: the recognition callback runs on SFSpeech's
        // internal queue, not MainActor. The script tokens are a `[String]`
        // value (Sendable), but the moving pointer needs synchronized access.
        let pointer = OSAllocatedUnfairLock<Int>(initialState: 0)
        let normalized = script.map(\.normalized)

        // Capture explicitly with @Sendable so the closure is nonisolated.
        let handler: @Sendable (SFSpeechRecognitionResult?, Error?) -> Void = { result, error in
            if let error {
                let nsError = error as NSError
                // SFSpeech raises this code when we manually cancel — treat as graceful finish.
                if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 216 {
                    continuation.finish()
                    return
                }
                continuation.finish(throwing: error)
                return
            }
            guard let result else { return }
            let transcript = result.bestTranscription.formattedString
                .lowercased()
                .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }
                .split(whereSeparator: \.isWhitespace)
                .map(String.init)

            pointer.withLock { current in
                for spoken in transcript {
                    let lookahead = min(current + 3, normalized.count)
                    for candidate in current..<lookahead where normalized[candidate] == spoken {
                        current = candidate + 1
                        continuation.yield(candidate)
                        break
                    }
                    if current >= normalized.count { break }
                }
                if current >= normalized.count {
                    continuation.finish()
                }
            }
        }
        task = recognizer.recognitionTask(with: request, resultHandler: handler)
    }

    private nonisolated static func requestAuthorization() async -> Bool {
        await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
    }
}
