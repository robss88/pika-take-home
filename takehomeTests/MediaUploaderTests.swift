import Foundation
import Testing
@testable import takehome

@Suite("MediaUploader")
struct MediaUploaderTests {
    private static let voiceURL = URL(fileURLWithPath: "/tmp/test-voice.m4a")

    @Test func mock_uploader_returns_voice_prefixed_key_for_voice_kind() async throws {
        let uploader = MockMediaUploader(delay: .zero)
        let key = try await uploader.upload(Self.voiceURL, kind: .voice)
        #expect(key.hasPrefix("voice/"))
    }

    @Test func mock_uploader_throws_when_shouldFail_is_true() async {
        let uploader = MockMediaUploader(delay: .zero, shouldFail: true)
        do {
            _ = try await uploader.upload(Self.voiceURL, kind: .voice)
            Issue.record("expected upload to throw")
        } catch {
            // expected — the synthesized URLError propagates as APIError.transport
        }
    }
}
