import Foundation

@MainActor
protocol SpeechAligner: AnyObject {
    /// Begin aligning. Emits the highest token index that has been recognized
    /// so far. Indices are monotonically non-decreasing.
    func align(script: [ScriptTokenizer.Token]) -> AsyncThrowingStream<Int, Error>
    func cancel()
}

enum SpeechAlignerError: Error, LocalizedError {
    case permissionDenied
    case unavailable
    case engineFailed(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied: return "Speech recognition permission is required."
        case .unavailable: return "Speech recognition isn't available on this device."
        case .engineFailed(let msg): return "Couldn't start speech recognition: \(msg)"
        }
    }
}
