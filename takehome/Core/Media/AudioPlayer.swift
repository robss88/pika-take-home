import AVFoundation
import Foundation

@MainActor
final class AudioPlayer {
    private var player: AVAudioPlayer?

    /// Loop an mp3/m4a from the app bundle indefinitely until `stop()`.
    func loop(bundleResource: String, withExtension ext: String, volume: Float = 0.6) {
        guard let url = Bundle.main.url(forResource: bundleResource, withExtension: ext) else {
            // Asset missing: degrade silently. README documents this seam.
            return
        }
        loop(url: url, volume: volume)
    }

    func loop(url: URL, volume: Float = 0.6) {
        do {
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try? session.setActive(true, options: [])
            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = -1
            p.volume = volume
            p.prepareToPlay()
            p.play()
            self.player = p
        } catch {
            // Best-effort; ambient audio is non-essential.
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }

    /// One-shot playback (e.g. tapping Play on the voice-recording review).
    /// Returns when playback completes or `cancel` is called.
    func playOnce(url: URL) async {
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()
            p.play()
            self.player = p
            while p.isPlaying {
                try? await Task.sleep(for: .milliseconds(50))
                if Task.isCancelled { p.stop(); break }
            }
        } catch {
            // Ignore; surface as silent no-op.
        }
    }
}
