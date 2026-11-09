import AVFoundation

/// Short sound effects. Silent when Sound is off in Settings or the ringer switch is muted.
@MainActor
final class SoundPlayer {
    enum Effect: String, CaseIterable { case flap, score, crash }

    private var players: [Effect: AVAudioPlayer] = [:]

    init() {
        // Ambient: respects the silent switch and lets the player's music keep playing.
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        for effect in Effect.allCases {
            guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "caf"),
                  let player = try? AVAudioPlayer(contentsOf: url) else { continue }
            player.prepareToPlay()
            players[effect] = player
        }
    }

    func play(_ effect: Effect) {
        guard UserDefaults.standard.bool(forKey: SettingsKey.sound), let player = players[effect] else { return }
        player.currentTime = 0
        player.play()
    }
}
