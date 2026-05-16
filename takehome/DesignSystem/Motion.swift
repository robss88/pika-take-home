import SwiftUI

/// Motion tokens. Each name captures the *intent* of a specific motion rather
/// than the underlying spring/curve numbers — so a designer asking for "softer
/// card entrance" is a one-line edit and a `grep` finds every place that
/// motion is reused.
///
/// Springs are tuned per-motion because different transitions need different
/// feels (a tap response is fast and tight, a hero card entrance is slower
/// and slightly bouncy). When two motions read as the same category but with
/// different damping, they earn separate tokens — collapsing them would
/// homogenize the app's feel.
enum Motion {
    // MARK: - Springs

    /// Default spring entrance for views appearing on screen (used by
    /// `View.springAppear`). Slightly bouncy, medium speed.
    static let entrance = Animation.spring(response: 0.5, dampingFraction: 0.82)

    /// Hero card entrance — the success ID card. Softer landing.
    static let heroEntrance = Animation.spring(response: 0.65, dampingFraction: 0.72)

    /// Tap response (shutter button press). Fast and tight.
    static let press = Animation.spring(response: 0.25, dampingFraction: 0.7)

    /// Progress-bar fill animating to a new step.
    static let progressFill = Animation.spring(response: 0.45, dampingFraction: 0.85)

    /// Voice recorder phase transitions.
    static let voicePhase = Animation.spring(response: 0.4, dampingFraction: 0.85)

    /// Record-button morph between idle / listening / review.
    static let recordMorph = Animation.spring(response: 0.45, dampingFraction: 0.78)

    // MARK: - Eases

    /// Short generic fade (placeholder appearance, opacity swaps).
    static let fade = Animation.easeInOut(duration: 0.2)

    /// Camera preview fade-in once the session is ready.
    static let cameraFade = Animation.easeOut(duration: 0.2)

    /// Word-by-word highlight tween in the voice script.
    static let highlight = Animation.easeOut(duration: 0.22)

    /// Camera flash flicker — quick and decisive.
    static let flash = Animation.easeInOut(duration: 0.12)

    /// Looping listening-ring pulse on the record button. Infinite.
    static let pulse = Animation.easeInOut(duration: 1.2)
        .repeatForever(autoreverses: true)
}
