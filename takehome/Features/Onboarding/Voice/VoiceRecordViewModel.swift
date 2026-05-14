import Foundation
import Observation

@Observable
final class VoiceRecordViewModel {
    enum Phase: Equatable {
        case idle
        case listening
        case review
        case playing
    }

    /// The script the user is asked to read. Backend candidate to personalize.
    static let defaultScript = """
    My best self is just ahead. The life I've always wanted is here. \
    My goals are in reach. I love affirmations.
    """

    let tokens: [ScriptTokenizer.Token]
    private(set) var phase: Phase = .idle
    private(set) var highlightedIndex: Int = -1   // -1 means "nothing highlighted yet"
    private(set) var recordingURL: URL? = nil
    var error: String? = nil

    private let recorder: any AudioRecorder
    private let aligner: any SpeechAligner
    private let player = AudioPlayer()
    private var alignmentTask: Task<Void, Never>?
    private let onAccepted: (URL) -> Void
    private let onBack: () -> Void

    init(
        recorder: any AudioRecorder,
        aligner: any SpeechAligner,
        script: String = VoiceRecordViewModel.defaultScript,
        onAccepted: @escaping (URL) -> Void,
        onBack: @escaping () -> Void
    ) {
        self.tokens = ScriptTokenizer.tokenize(script)
        self.recorder = recorder
        self.aligner = aligner
        self.onAccepted = onAccepted
        self.onBack = onBack
    }

    func toggleRecord() async {
        switch phase {
        case .idle, .review:
            await beginRecording()
        case .listening:
            await endRecording()
        case .playing:
            break
        }
    }

    func reRecord() {
        highlightedIndex = -1
        recordingURL = nil
        phase = .idle
    }

    func accept() {
        guard let url = recordingURL else { return }
        onAccepted(url)
    }

    func playBack() async {
        guard let url = recordingURL, phase != .playing else { return }
        phase = .playing
        await player.playOnce(url: url)
        phase = .review
    }

    func back() {
        cancelEverything()
        onBack()
    }

    // MARK: - Internals

    private func beginRecording() async {
        cancelEverything()
        error = nil
        highlightedIndex = -1
        do {
            let url = try await recorder.start()
            recordingURL = url
            phase = .listening
            startAlignment()
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            phase = .idle
        }
    }

    private func endRecording() async {
        alignmentTask?.cancel()
        alignmentTask = nil
        aligner.cancel()
        recordingURL = await recorder.stop() ?? recordingURL
        phase = recordingURL == nil ? .idle : .review
    }

    private func startAlignment() {
        alignmentTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                for try await index in self.aligner.align(script: self.tokens) {
                    self.highlightedIndex = max(self.highlightedIndex, index)
                }
            } catch {
                self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    private func cancelEverything() {
        alignmentTask?.cancel()
        alignmentTask = nil
        aligner.cancel()
        recorder.cancel()
    }
}
