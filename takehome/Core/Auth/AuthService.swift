import Foundation

enum AuthMethod: Sendable {
    case phone(E164)
    case google
    case email
}

protocol AuthService: Sendable {
    nonisolated func signIn(_ method: AuthMethod) async throws -> AuthToken
}

// MARK: - Live

nonisolated struct LiveAuthService: AuthService {
    let api: any APIClient

    func signIn(_ method: AuthMethod) async throws -> AuthToken {
        let body: AuthRequest
        switch method {
        case .phone(let e164):
            body = AuthRequest(method: .phone, phone: e164.e164String)
        case .google:
            body = AuthRequest(method: .google, phone: nil)
        case .email:
            body = AuthRequest(method: .email, phone: nil)
        }
        let endpoint: Endpoint<AuthToken> = .json(.post, APIPaths.signIn, body: body)
        return try await api.send(endpoint)
    }
}

// MARK: - Mock

nonisolated struct MockAuthService: AuthService {
    /// Set to true in tests to exercise the failure path.
    var shouldFail: Bool = false
    var delay: Duration = .milliseconds(600)

    func signIn(_ method: AuthMethod) async throws -> AuthToken {
        try await Task.sleep(for: delay)
        if shouldFail {
            throw APIError.status(401, Data())
        }
        return AuthToken(value: "mock-token")
    }
}
