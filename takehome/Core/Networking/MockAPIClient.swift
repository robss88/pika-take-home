import Foundation
import os

/// Test double for `APIClient`.
///
/// Lookups are by `METHOD path`. Tests register handlers per endpoint and
/// assert against `recordedCalls`. If the app sends an endpoint the mock
/// hasn't been configured for, `send` throws `APIError.mockUnconfigured` so
/// missing wiring is loud rather than silent.
nonisolated final class MockAPIClient: APIClient, Sendable {
    struct State {
        var handlers: [String: @Sendable (Data?) async throws -> Data] = [:]
        var recordedCalls: [String] = []
    }

    private let state = OSAllocatedUnfairLock<State>(initialState: State())
    let artificialDelay: Duration

    init(artificialDelay: Duration = .milliseconds(50)) {
        self.artificialDelay = artificialDelay
    }

    /// Default seed used by the app in `AppEnvironment.mock` so that previews
    /// and the simulator both work end-to-end without manual wiring.
    static func preloaded() -> MockAPIClient {
        let client = MockAPIClient()
        client.stubJSON(.post, APIPaths.signIn, with: AuthToken(value: "mock-token"))
        client.stubJSON(.post, APIPaths.createAISelf, with: IDCard.canned)
        return client
    }

    func stub(
        _ method: HTTPMethod,
        _ path: String,
        thenThrowing error: APIError
    ) {
        let key = key(method, path)
        state.withLock { $0.handlers[key] = { _ in throw error } }
    }

    func stubJSON<R: Encodable & Sendable>(
        _ method: HTTPMethod,
        _ path: String,
        with value: R
    ) {
        let key = key(method, path)
        let data = (try? JSONEncoder.default.encode(value)) ?? Data()
        state.withLock { $0.handlers[key] = { _ in data } }
    }

    func recordedCalls() -> [String] {
        state.withLock { $0.recordedCalls }
    }

    func send<R>(_ endpoint: Endpoint<R>) async throws -> R {
        let key = key(endpoint.method, endpoint.path)
        state.withLock { $0.recordedCalls.append(key) }
        try await Task.sleep(for: artificialDelay)
        try Task.checkCancellation()

        let handler = state.withLock { $0.handlers[key] }
        guard let handler else { throw APIError.mockUnconfigured(key) }
        let data = try await handler(endpoint.body)
        do {
            return try endpoint.decode(data)
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError.decode(String(describing: error))
        }
    }

    private nonisolated func key(_ method: HTTPMethod, _ path: String) -> String {
        "\(method.rawValue) \(path)"
    }
}
