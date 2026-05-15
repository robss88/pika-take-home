import SwiftUI

/// A navigable destination owned by a feature.
///
/// Each feature defines its own conforming `Route` (typically an enum of
/// step payloads) and a `Context` carrying the dependencies its destinations
/// need (services, coordinator, …). View construction lives next to the
/// route definition, so neither `AppShell` nor feature shells grow a central
/// `switch` as the app adds destinations.
@MainActor
protocol Route: Hashable {
    associatedtype Destination: View
    associatedtype Context

    @ViewBuilder
    func destination(_ context: Context) -> Destination
}
