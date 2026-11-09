import Foundation
import Testing
@testable import FlappyDog

struct GameWorldTests {
    typealias W = GameWorld

    /// A world where the dog flies level (no gravity, no flap) through gaps whose bottom edge sits at `gapBottom`.
    private func levelWorld(gapBottom: Double, gap: Double = 200) -> GameWorld {
        let center = gapBottom + gap / 2
        let fraction = (center - W.groundHeight) / (W.height - W.groundHeight)
        var config = GameConfig.normal
        config.gravity = 0
        config.flapSpeed = 0
        config.gapHeight = gap
        config.gapCenterRange = fraction...fraction
        config.rampEvery = 0
        var world = GameWorld(config: config, seed: 1)
        world.flap()
        return world
    }

    private func run(_ world: inout GameWorld, seconds: Double) -> [GameWorld.Event] {
        (0..<Int(seconds / W.step)).flatMap { _ in world.step() }
    }

    @Test func nothingMovesBeforeTheFirstFlap() {
        var world = GameWorld(seed: 1)
        _ = run(&world, seconds: 2)
        #expect(world.dogY == W.playCenter)
        #expect(world.pillars.isEmpty)
    }

    @Test func flapSetsSpeedInsteadOfAdding() {
        var world = GameWorld(seed: 1)
        world.flap()
        world.flap()
        #expect(world.dogVelocity == GameConfig.normal.flapSpeed)
        _ = run(&world, seconds: 0.1)
        world.flap()
        #expect(world.dogVelocity == GameConfig.normal.flapSpeed)
    }

    @Test func fallSpeedIsCapped() {
        var config = GameConfig.normal
        config.flapSpeed = 0
        var world = GameWorld(config: config, seed: 1)
        world.flap()
        _ = run(&world, seconds: 0.6)
        #expect(world.dogVelocity == -config.maxFallSpeed)
    }

    @Test func groundCrashThenLand() {
        var world = GameWorld(seed: 1)
        world.flap()
        let events = run(&world, seconds: 3)
        #expect(events.filter { $0 == .crashed }.count == 1)
        #expect(events.last == .landed)
        #expect(world.landed)
        #expect(world.dogY == W.groundHeight + W.dogRadius)
    }

    @Test func ceilingCrash() {
        var config = GameConfig.normal
        config.gravity = 0
        var world = GameWorld(config: config, seed: 1)
        world.flap()
        _ = run(&world, seconds: 1)
        #expect(world.crashed)
        #expect(world.score == 0)
    }

    @Test func scoresExactlyOncePerPillar() {
        var world = levelWorld(gapBottom: W.playCenter - 100)
        var events: [GameWorld.Event] = []
        while world.score == 0 { events += world.step() }
        events += run(&world, seconds: 0.5)
        #expect(events.filter { $0 == .scored }.count == 1)
        #expect(world.score == 1)
        #expect(!world.crashed)
        _ = run(&world, seconds: 10)
        #expect(world.score > 3)
        #expect(!world.crashed)
    }

    @Test func pillarEdgeCrashes() {
        var world = levelWorld(gapBottom: W.playCenter - W.hitRadius * 0.3)
        _ = run(&world, seconds: 3)
        #expect(world.crashed)
        #expect(world.score == 0)
    }

    @Test func nearMissInsideForgivingHitboxIsNotACrash() {
        // The sprite overlaps the bone by 15% of its radius, but the hitbox does not.
        var world = levelWorld(gapBottom: W.playCenter - W.dogRadius * 0.85)
        _ = run(&world, seconds: 3)
        #expect(!world.crashed)
        #expect(world.score == 1)
    }

    @Test func seededRunsRepeat() {
        var a = GameWorld(seed: 7), b = GameWorld(seed: 7)
        a.flap(); b.flap()
        _ = run(&a, seconds: 0.3); _ = run(&b, seconds: 0.3)
        #expect(a.pillars == b.pillars)
    }

    @Test func fixedStepIsFrameRateIndependent() {
        var a = GameWorld(seed: 3), b = GameWorld(seed: 3)
        a.flap(); b.flap()
        for _ in 0..<60 { _ = a.update(by: 1.0 / 60) }
        for _ in 0..<120 { _ = b.update(by: 1.0 / 120) }
        #expect(abs(a.dogY - b.dogY) < 5) // at most one step apart from float rounding
    }

    @Test func rampStopsAtItsCaps() {
        let normal = GameConfig.normal
        #expect(normal.speedFactor(forScore: 0) == 1)
        #expect(normal.gapHeight(forScore: 9) == 200)
        #expect(abs(normal.speedFactor(forScore: 10) - 1.05) < 1e-9)
        #expect(normal.gapHeight(forScore: 10) == 195)
        #expect(normal.speedFactor(forScore: 1000) == 1.4)
        #expect(normal.gapHeight(forScore: 1000) == 170)
        #expect(GameConfig.relaxed.speedFactor(forScore: 1000) == 1)
        #expect(GameConfig.relaxed.gapHeight(forScore: 1000) == 260)
    }
}

struct ScoreStoreTests {
    private func makeStore() -> ScoreStore {
        let name = "test-\(UUID().uuidString)"
        return ScoreStore(defaults: UserDefaults(suiteName: name)!)
    }

    @Test func bestOnlyGoesUp() {
        let store = makeStore()
        #expect(!store.record(0, relaxed: false))
        #expect(store.record(5, relaxed: false))
        #expect(!store.record(3, relaxed: false))
        #expect(!store.record(5, relaxed: false))
        #expect(store.best(relaxed: false) == 5)
    }

    @Test func modesAreStoredSeparately() {
        let store = makeStore()
        store.record(8, relaxed: false)
        store.record(2, relaxed: true)
        #expect(store.best(relaxed: false) == 8)
        #expect(store.best(relaxed: true) == 2)
    }
}
