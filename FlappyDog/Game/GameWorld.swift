import Foundation

/// The rules of the game, with no SpriteKit in it. y points up, the origin is the bottom-left of the 390 × 844 world.
struct GameWorld: Sendable {
    struct Pillar: Sendable, Equatable {
        var x: Double
        var gapCenter: Double
        var gapHeight: Double
        var scored = false
        var gapBottom: Double { gapCenter - gapHeight / 2 }
        var gapTop: Double { gapCenter + gapHeight / 2 }
    }

    enum Event: Sendable, Equatable { case scored, crashed, landed }

    static let width = 390.0
    static let height = 844.0
    static let groundHeight = 110.0
    static let playCenter = groundHeight + (height - groundHeight) / 2
    static let dogX = 120.0
    static let dogRadius = 26.0
    /// Forgiving hitbox: 70% of the sprite.
    static let hitRadius = dogRadius * 0.7
    static let pillarWidth = 72.0
    /// Pillars collide slightly smaller than their art.
    static let pillarInset = 4.0
    static let step = 1.0 / 120

    let config: GameConfig
    /// Extra visible width on each side of the world (wide screens), so pillars spawn and despawn off screen.
    var spawnMargin = 0.0

    private(set) var dogY = playCenter
    private(set) var dogVelocity = 0.0
    private(set) var pillars: [Pillar] = []
    private(set) var score = 0
    private(set) var started = false
    private(set) var crashed = false
    private(set) var landed = false
    private var accumulator = 0.0
    private var rng: SplitMix64

    init(config: GameConfig = .normal, seed: UInt64 = .random(in: 0 ... .max)) {
        self.config = config
        rng = SplitMix64(state: seed)
    }

    var speedFactor: Double { config.speedFactor(forScore: score) }
    private var spawnX: Double { Self.width + spawnMargin + Self.pillarWidth / 2 }
    private var pitch: Double { config.pillarSpacing + Self.pillarWidth }

    /// A flap sets the upward speed rather than adding to it, so every tap feels the same.
    mutating func flap() {
        guard !crashed else { return }
        if !started {
            started = true
            spawnPillar(at: spawnX)
        }
        dogVelocity = config.flapSpeed
    }

    /// Advances by real time in fixed steps, so 60 Hz and 120 Hz screens play the same.
    mutating func update(by dt: Double) -> [Event] {
        accumulator += min(max(dt, 0), 0.25)
        var events: [Event] = []
        while accumulator >= Self.step {
            accumulator -= Self.step
            events += step()
        }
        return events
    }

    mutating func step() -> [Event] {
        guard started, !landed else { return [] }
        var events: [Event] = []

        dogVelocity = max(dogVelocity - config.gravity * Self.step, -config.maxFallSpeed)
        dogY += dogVelocity * Self.step

        if crashed {
            // After a crash the dog just drops to the ground.
            if dogY - Self.dogRadius <= Self.groundHeight {
                dogY = Self.groundHeight + Self.dogRadius
                landed = true
                events.append(.landed)
            }
            return events
        }

        let dx = config.scrollSpeed * speedFactor * Self.step
        for i in pillars.indices { pillars[i].x -= dx }
        pillars.removeAll { $0.x < -spawnMargin - Self.pillarWidth }
        if let last = pillars.last, last.x <= spawnX - pitch {
            spawnPillar(at: last.x + pitch)
        }

        for i in pillars.indices where !pillars[i].scored && pillars[i].x <= Self.dogX {
            pillars[i].scored = true
            score += 1
            events.append(.scored)
        }

        if hitsSomething() {
            crashed = true
            dogVelocity = min(dogVelocity, 0)
            events.append(.crashed)
        }
        return events
    }

    private mutating func spawnPillar(at x: Double) {
        let fraction = Double.random(in: config.gapCenterRange, using: &rng)
        let center = Self.groundHeight + (Self.height - Self.groundHeight) * fraction
        pillars.append(Pillar(x: x, gapCenter: center, gapHeight: config.gapHeight(forScore: score)))
    }

    private func hitsSomething() -> Bool {
        if dogY - Self.hitRadius <= Self.groundHeight || dogY + Self.hitRadius >= Self.height { return true }
        let half = Self.pillarWidth / 2 - Self.pillarInset
        return pillars.contains { p in
            let minX = p.x - half, maxX = p.x + half
            return circleHits(minX: minX, maxX: maxX, minY: -.infinity, maxY: p.gapBottom - Self.pillarInset)
                || circleHits(minX: minX, maxX: maxX, minY: p.gapTop + Self.pillarInset, maxY: .infinity)
        }
    }

    private func circleHits(minX: Double, maxX: Double, minY: Double, maxY: Double) -> Bool {
        let dx = Self.dogX - min(max(Self.dogX, minX), maxX)
        let dy = dogY - min(max(dogY, minY), maxY)
        return dx * dx + dy * dy < Self.hitRadius * Self.hitRadius
    }
}

/// Small seeded generator so test runs repeat exactly.
struct SplitMix64: RandomNumberGenerator, Sendable {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
