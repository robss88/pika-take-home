import Foundation

/// Real `URLSession` async/await `APIClient`.
///
/// Fully implemented; flipping `AppEnvironment.resolved()` from `.mock` to
/// `.live` is the only switch needed once `APIConfig.live.baseURL` points at
/// a real backend.
nonisolated final class LiveAPIClient: APIClient {
    private let config: APIConfig
    private let session: URLSession

    init(config: APIConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    func send<R>(_ endpoint: Endpoint<R>) async throws -> R {
        let request = try buildRequest(for: endpoint)
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw APIError.cancelled
        } catch let urlError as URLError {
            throw APIError.transport(urlError)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.transport(URLError(.badServerResponse))
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.status(http.statusCode, data)
        }

        do {
            return try endpoint.decode(data)
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError.decode(String(describing: error))
        }
    }

    private func buildRequest<R>(for endpoint: Endpoint<R>) throws -> URLRequest {
        var components = URLComponents(
            url: config.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        )
        if !endpoint.query.isEmpty {
            components?.queryItems = endpoint.query
        }
        guard let url = components?.url else {
            throw APIError.transport(URLError(.badURL))
        }
        var request = URLRequest(url: url, timeoutInterval: config.timeout)
        request.httpMethod = endpoint.method.rawValue
        for (k, v) in config.defaultHeaders { request.setValue(v, forHTTPHeaderField: k) }
        for (k, v) in endpoint.headers { request.setValue(v, forHTTPHeaderField: k) }
        request.httpBody = endpoint.body
        return request
    }
}
