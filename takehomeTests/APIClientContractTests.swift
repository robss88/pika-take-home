import Foundation
import Testing
@testable import takehome

/// Verifies the `APIClient` seam: stubbing returns the canned response,
/// unconfigured endpoints fail loudly, and cancellation propagates.
@Suite("APIClient contract")
struct APIClientContractTests {
    @Test func returns_stubbed_response_for_registered_endpoint() async throws {
        let mock = MockAPIClient(artificialDelay: .zero)
        mock.stubJSON(.post, "/v1/ai-selves", with: IDCard.canned)

        let endpoint: Endpoint<IDCard> = .json(.post, "/v1/ai-selves")
        let result = try await mock.send(endpoint)
        #expect(result == IDCard.canned)
        #expect(mock.recordedCalls() == ["POST /v1/ai-selves"])
    }

    @Test func unconfigured_endpoint_throws_mockUnconfigured() async {
        let mock = MockAPIClient(artificialDelay: .zero)
        let endpoint: Endpoint<IDCard> = .json(.post, "/v1/missing")

        await #expect(throws: APIError.self) {
            _ = try await mock.send(endpoint)
        }
    }

    @Test func stubbed_error_propagates_to_caller() async {
        let mock = MockAPIClient(artificialDelay: .zero)
        mock.stub(.post, "/v1/auth/phone", thenThrowing: .status(401, Data()))
        let endpoint: Endpoint<AuthToken> = .json(.post, "/v1/auth/phone")

        await #expect(throws: APIError.self) {
            _ = try await mock.send(endpoint)
        }
    }

    @Test func cancellation_surfaces_as_cancelled_error() async {
        let mock = MockAPIClient(artificialDelay: .seconds(2))
        mock.stubJSON(.get, "/v1/slow", with: AuthToken(value: "x"))
        let endpoint: Endpoint<AuthToken> = .json(.get, "/v1/slow")

        let task = Task {
            try await mock.send(endpoint)
        }
        task.cancel()
        await #expect(throws: Error.self) {
            _ = try await task.value
        }
    }
}
