import SwiftUI

/// Links SwiftUI and the scene: owns the world, reacts to its events and holds what the overlays show.
@MainActor @Observable
final class GameModel {
    private(set) var phase: GamePhase = .home
    private(set) var score = 0
    private(set) var best = 0
    private(set) var isNewBest = false
    private(set) var canRestart = true

    @ObservationIgnored private(set) var world = GameWorld()
    @ObservationIgnored let scene: GameScene
    @ObservationIgnored private let store = ScoreStore()
    @ObservationIgnored private let sound = SoundPlayer()
    @ObservationIgnored private let haptics = Haptics()
    @ObservationIgnored private var relaxed = false
    @ObservationIgnored private let isUITest = ProcessInfo.processInfo.arguments.contains("-uitest")

    init() {
        scene = GameScene()
        scene.model = self
        refreshBest()
    }

    /// Re-reads the mode and its best score (after Settings closes).
    func refreshBest() {
        relaxed = UserDefaults.standard.bool(forKey: SettingsKey.relaxed)
        best = store.best(relaxed: relaxed)
    }

    func play() {
        guard phase != .gameOver || canRestart else { return }
        refreshBest()
        let config: GameConfig = isUITest ? .uiTest : relaxed ? .relaxed : .normal
        world = GameWorld(config: config, seed: isUITest ? 42 : .random(in: 0 ... .max))
        world.spawnMargin = scene.spawnMargin
        score = 0
        isNewBest = false
        scene.reset()
        phase = .ready
    }

    /// A tap on the play area, or the space bar.
    func tap() {
        switch phase {
        case .ready:
            phase = .playing
            flap()
        case .playing:
            flap()
        default:
            break
        }
    }

    private func flap() {
        guard !world.crashed else { return }
        world.flap()
        scene.dogFlapped()
        sound.play(.flap)
        haptics.flap()
    }

    func pause() {
        guard phase == .playing, !world.crashed else { return }
        phase = .paused
    }

    func resume() {
        guard phase == .paused else { return }
        phase = .playing
    }

    func goHome() {
        refreshBest()
        scene.reset()
        phase = .home
    }

    /// Called by the scene every frame.
    func tick(_ dt: Double) {
        guard phase == .playing else { return }
        for event in world.update(by: dt) {
            switch event {
            case .scored:
                score = world.score
                sound.play(.score)
                haptics.score()
            case .crashed:
                sound.play(.crash)
                haptics.crash()
                scene.crashEffects()
            case .landed:
                finish()
            }
        }
    }

    private func finish() {
        isNewBest = store.record(score, relaxed: relaxed)
        best = store.best(relaxed: relaxed)
        phase = .gameOver
        canRestart = false
        // Ignore a panicked tap right after the crash.
        Task {
            try? await Task.sleep(for: .seconds(0.5))
            canRestart = true
        }
        AccessibilityNotification.Announcement("Game over. Score \(score). Best \(best).").post()
    }
}
