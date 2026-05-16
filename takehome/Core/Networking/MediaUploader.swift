import Foundation

/// What kind of asset is being uploaded. Used by `MediaUploader` to namespace
/// server-side keys; downstream the key gets passed to `OnboardingClient`.
nonisolated enum MediaKind: String, Sendable {
    case voice
    case selfie
}

/// Pre-upload seam: take a local file and return the server-side key the
/// rest of the flow should reference. Today the live client just echoes the
/// path; when the backend is ready it'll multipart-upload and return a real
/// S3-ish key with no changes to call sites.
protocol MediaUploader: Sendable {
    nonisolated func upload(_ localURL: URL, kind: MediaKind) async throws -> String
}

// MARK: - Live

nonisolated struct LiveMediaUploader: MediaUploader {
    let api: any APIClient

    func upload(_ localURL: URL, kind: MediaKind) async throws -> String {
        // TODO(backend): multipart-POST to /v1/uploads, return `{ key }`.
        // The seam matches the eventual API contract — see "Open questions
        // for the backend" in README. Echoing the path keeps the flow live.
        return localURL.absoluteString
    }
}

// MARK: - Mock

nonisolated struct MockMediaUploader: MediaUploader {
    var delay: Duration = .milliseconds(450)
    var shouldFail: Bool = false

    func upload(_ localURL: URL, kind: MediaKind) async throws -> String {
        try await Task.sleep(for: delay)
        if shouldFail {
            throw APIError.transport(URLError(.networkConnectionLost))
        }
        return "\(kind.rawValue)/\(UUID().uuidString).key"
    }
}
