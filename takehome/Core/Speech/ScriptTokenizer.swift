import Foundation

nonisolated enum ScriptTokenizer {
    /// Split a script into normalized tokens for alignment.
    /// The displayed words preserve original casing/punctuation; matching uses
    /// the normalized form returned in `normalized`.
    nonisolated struct Token: Hashable, Sendable {
        let display: String     // "Self." (what we render)
        let normalized: String  // "self"  (what we match against)
    }

    static func tokenize(_ script: String) -> [Token] {
        script
            .split(whereSeparator: { $0.isWhitespace })
            .map { word in
                let display = String(word)
                let normalized = display
                    .lowercased()
                    .filter { $0.isLetter || $0.isNumber }
                return Token(display: display, normalized: normalized)
            }
            .filter { !$0.normalized.isEmpty }
    }
}
