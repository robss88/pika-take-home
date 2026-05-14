import Foundation
import Testing
@testable import takehome

@Suite("ScriptTokenizer")
struct ScriptTokenizerTests {
    @Test func splits_on_whitespace_and_normalizes_letters() {
        let tokens = ScriptTokenizer.tokenize("My best self.")
        #expect(tokens.map(\.normalized) == ["my", "best", "self"])
        #expect(tokens.map(\.display) == ["My", "best", "self."])
    }

    @Test func strips_punctuation_when_normalizing() {
        let tokens = ScriptTokenizer.tokenize("Hello, world!")
        #expect(tokens.map(\.normalized) == ["hello", "world"])
    }

    @Test func keeps_alphanumerics_in_normalized_form() {
        let tokens = ScriptTokenizer.tokenize("Track 42 — bpm 120")
        #expect(tokens.map(\.normalized) == ["track", "42", "bpm", "120"])
    }

    @Test func drops_tokens_that_normalize_to_empty() {
        let tokens = ScriptTokenizer.tokenize("foo --- bar")
        #expect(tokens.map(\.normalized) == ["foo", "bar"])
    }

    @Test func collapses_repeated_whitespace() {
        let tokens = ScriptTokenizer.tokenize("a\n\nb   c")
        #expect(tokens.map(\.normalized) == ["a", "b", "c"])
    }

    @Test func empty_input_produces_no_tokens() {
        #expect(ScriptTokenizer.tokenize("").isEmpty)
        #expect(ScriptTokenizer.tokenize("   ").isEmpty)
    }
}
