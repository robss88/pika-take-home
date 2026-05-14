import Foundation
import Testing
@testable import takehome

@MainActor
@Suite("VoiceRecordViewModel")
struct VoiceRecordViewModelTests {
    @Test func happy_path_advances_through_phases_and_yields_recording() async {
        let recorder = StubAudioRecorder()
        let aligner = FakeTimedSpeechAligner()
        aligner.intervalPerWord = .milliseconds(1)

        var captured: URL?
        let vm = VoiceRecordViewModel(
            recorder: recorder,
            aligner: aligner,
            script: "best self ahead",
            onAccepted: { captured = $0 },
            onBack: { }
        )

        await vm.toggleRecord()
        #expect(vm.phase == .listening)

        try? await Task.sleep(for: .milliseconds(50))
        await vm.toggleRecord()
        #expect(vm.phase == .review)
        #expect(vm.recordingURL != nil)

        vm.accept()
        #expect(captured != nil)
    }

    @Test func recorder_failure_keeps_phase_idle_and_surfaces_error() async {
        let recorder = StubAudioRecorder(shouldFail: true)
        let vm = VoiceRecordViewModel(
            recorder: recorder,
            aligner: FakeTimedSpeechAligner(),
            script: "best self",
            onAccepted: { _ in Issue.record("should not advance") },
            onBack: { }
        )

        await vm.toggleRecord()
        #expect(vm.phase == .idle)
        #expect(vm.error != nil)
    }

    @Test func reRecord_resets_state() async {
        let recorder = StubAudioRecorder()
        let vm = VoiceRecordViewModel(
            recorder: recorder,
            aligner: FakeTimedSpeechAligner(),
            script: "best self",
            onAccepted: { _ in },
            onBack: { }
        )

        await vm.toggleRecord()
        await vm.toggleRecord()
        #expect(vm.phase == .review)
        vm.reRecord()
        #expect(vm.phase == .idle)
        #expect(vm.recordingURL == nil)
    }
}

// MARK: - Stub recorder

@MainActor
private final class StubAudioRecorder: AudioRecorder {
    var isRecording: Bool = false
    var shouldFail: Bool
    private var stubURL: URL?

    init(shouldFail: Bool = false) { self.shouldFail = shouldFail }

    func requestPermission() async -> Bool { true }
    func start() async throws -> URL {
        if shouldFail { throw AudioRecorderError.sessionFailed("stub") }
        isRecording = true
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("stub-\(UUID().uuidString).m4a")
        FileManager.default.createFile(atPath: url.path, contents: Data())
        stubURL = url
        return url
    }
    func stop() async -> URL? {
        isRecording = false
        return stubURL
    }
    func cancel() {
        isRecording = false
        stubURL = nil
    }
}
