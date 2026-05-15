import Foundation

nonisolated struct APIConfig: Sendable {
    let baseURL: URL
    let defaultHeaders: [String: String]
    let timeout: TimeInterval

    static let live = APIConfig(
        // Placeholder — the backend doesn't exist yet. Swap this URL (or read
        // it from Info.plist) when the real service comes online; nothing else
        // needs to change. Endpoint paths in `APIPaths` carry their own version
        // segment, so this URL holds only host + scheme.
        baseURL: URL(string: "https://api.pika.example")!,
        defaultHeaders: [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ],
        timeout: 20
    )
}
