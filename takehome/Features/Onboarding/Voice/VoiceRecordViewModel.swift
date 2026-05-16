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
    private(set) var isUploading: Bool = false
    private(set) var uploadedVoiceKey: String? = nil
    var error: String? = nil

    private let recorder: any AudioRecorder
    private let aligner: any SpeechAligner
    private let uploader: any MediaUploader
    private let player = AudioPlayer()
    private var alignmentTask: Task<Void, Never>?
    private let onAccepted: (URL) -> Void
    private let onBack: () -> Void

    init(
        recorder: any AudioRecorder,
        aligner: any SpeechAligner,
        uploader: any MediaUploader,
        script: String = VoiceRecordViewModel.defaultScript,
        onAccepted: @escaping (URL) -> Void,
        onBack: @escaping () -> Void
    ) {
        self.tokens = ScriptTokenizer.tokenize(script)
        self.recorder = recorder
        self.aligner = aligner
        self.uploader = uploader
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

    func accept() async {
        guard let url = recordingURL, !isUploading else { return }
        isUploading = true
        error = nil
        defer { isUploading = false }
        do {
            uploadedVoiceKey = try await uploader.upload(url, kind: .voice)
            onAccepted(url)
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
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
        // Optimistic UI: flip to `.listening` before awaiting the recorder so
        // the record button morphs immediately on tap. If the recorder fails
        // (permission denied, session error) we revert to `.idle` and surface
        // the error.
        phase = .listening
        do {
            recordingURL = try await recorder.start()
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
        // Optimistic UI: flip to `.review` before awaiting `recorder.stop()`
        // so the review row appears instantly on tap. If `stop()` somehow
        // returns nil with no cached URL we revert to `.idle`.
        phase = .review
        recordingURL = await recorder.stop() ?? recordingURL
        if recordingURL == nil { phase = .idle }
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
