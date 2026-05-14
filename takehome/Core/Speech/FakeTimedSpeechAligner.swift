import Foundation

/// Deterministic test/preview substitute for `LiveSpeechAligner`.
///
/// Emits `Int` indices on a fixed cadence so previews can demonstrate the
/// word-highlight animation without microphone access or speech permissions.
@MainActor
final class FakeTimedSpeechAligner: SpeechAligner {
    private var task: Task<Void, Never>?
    var intervalPerWord: Duration = .milliseconds(350)

    func align(script: [ScriptTokenizer.Token]) -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream { continuation in
            let interval = intervalPerWord
            let count = script.count
            self.task = Task { @MainActor [weak self] in
                guard self != nil else { continuation.finish(); return }
                for index in 0..<count {
                    do {
                        try await Task.sleep(for: interval)
                    } catch {
                        continuation.finish()
                        return
                    }
                    continuation.yield(index)
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor in self?.cancel() }
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
