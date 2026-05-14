import Foundation

nonisolated enum APIError: Error, Sendable {
    /// Connectivity / DNS / TLS / cancelled-by-system failure from URLSession.
    case transport(URLError)
    /// HTTP non-2xx response. Body is preserved for diagnostics.
    case status(Int, Data)
    /// JSON decode (or body construction) failure.
    case decode(String)
    /// The task was cancelled cooperatively.
    case cancelled
    /// The mock doesn't know how to answer this endpoint.
    case mockUnconfigured(String)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .transport(let urlError):
            return "Network problem: \(urlError.localizedDescription)"
        case .status(let code, _):
            return "Server returned HTTP \(code)."
        case .decode(let detail):
            return "Couldn't decode response: \(detail)"
        case .cancelled:
            return "The request was cancelled."
        case .mockUnconfigured(let path):
            return "Mock has no canned response for \(path)."
        }
    }
}
