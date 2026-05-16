import Foundation

/// HTTP verbs used by `Endpoint` descriptors. Raw values are wire-format
/// strings so they drop straight into `URLRequest.httpMethod`.
nonisolated enum HTTPMethod: String, Sendable {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}
