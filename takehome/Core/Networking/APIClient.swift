import Foundation

/// A single typed request descriptor.
///
/// `decode` is owned by the endpoint so call sites can keep their decoding
/// strategy local (custom dates, snake_case keys, etc.) without leaking that
/// concern into the client. The client just transports bytes.
nonisolated struct Endpoint<Response: Sendable>: Sendable {
    let method: HTTPMethod
    let path: String
    let query: [URLQueryItem]
    let body: Data?
    let headers: [String: String]
    let decode: @Sendable (Data) throws -> Response

    init(
        method: HTTPMethod,
        path: String,
        query: [URLQueryItem] = [],
        body: Data? = nil,
        headers: [String: String] = [:],
        decode: @escaping @Sendable (Data) throws -> Response
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.body = body
        self.headers = headers
        self.decode = decode
    }
}

nonisolated extension Endpoint where Response: Decodable {
    /// Convenience for endpoints with no body.
    static func json(
        _ method: HTTPMethod,
        _ path: String,
        query: [URLQueryItem] = [],
        headers: [String: String] = [:]
    ) -> Endpoint<Response> {
        Endpoint(
            method: method,
            path: path,
            query: query,
            body: nil,
            headers: headers,
            decode: jsonDecoder()
        )
    }

    /// Convenience for endpoints with a JSON body.
    static func json<Body: Encodable>(
        _ method: HTTPMethod,
        _ path: String,
        body: Body,
        query: [URLQueryItem] = [],
        headers: [String: String] = [:]
    ) -> Endpoint<Response> {
        let data = (try? JSONEncoder.default.encode(body)) ?? Data()
        return Endpoint(
            method: method,
            path: path,
            query: query,
            body: data,
            headers: headers,
            decode: jsonDecoder()
        )
    }

    private static func jsonDecoder() -> @Sendable (Data) throws -> Response {
        { data in
            do {
                return try JSONDecoder.default.decode(Response.self, from: data)
            } catch {
                throw APIError.decode(String(describing: error))
            }
        }
    }
}

protocol APIClient: Sendable {
    nonisolated func send<R>(_ endpoint: Endpoint<R>) async throws -> R
}

// MARK: - Shared JSON config

extension JSONDecoder {
    nonisolated static let `default`: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}

extension JSONEncoder {
    nonisolated static let `default`: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        e.dateEncodingStrategy = .iso8601
        return e
    }()
}
