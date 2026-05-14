import Foundation

nonisolated struct APIConfig: Sendable {
    let baseURL: URL
    let defaultHeaders: [String: String]
    let timeout: TimeInterval

    static let live = APIConfig(
        // Placeholder — the backend doesn't exist yet. Swap this URL (or read
        // it from Info.plist) when the real service comes online; nothing else
        // needs to change.
        baseURL: URL(string: "https://api.pika.example/v1")!,
        defaultHeaders: [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ],
        timeout: 20
    )
}
