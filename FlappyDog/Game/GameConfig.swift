import Foundation

/// Tuning values. Distances in points, speeds in points per second.
struct GameConfig: Equatable, Sendable {
    var gravity: Double
    var flapSpeed: Double
    var maxFallSpeed: Double
    var scrollSpeed: Double
    var gapHeight: Double
    /// Empty space between two pillar pairs.
    var pillarSpacing: Double
    /// Where the gap centre may sit, as a fraction of the play height.
    var gapCenterRange: ClosedRange<Double>
    /// Ramp up every this many points. 0 turns the ramp off.
    var rampEvery: Int
    var rampSpeedStep = 0.05
    var rampGapStep = 5.0
    var maxSpeedFactor = 1.4
    var minGapHeight = 170.0

    static let normal = GameConfig(
        gravity: 1600, flapSpeed: 480, maxFallSpeed: 800, scrollSpeed: 160,
        gapHeight: 200, pillarSpacing: 230, gapCenterRange: 0.25...0.75, rampEvery: 10)

    static let relaxed = GameConfig(
        gravity: 1400, flapSpeed: 450, maxFallSpeed: 700, scrollSpeed: 120,
        gapHeight: 260, pillarSpacing: 260, gapCenterRange: 0.30...0.70, rampEvery: 0)

    /// UI tests: the dog drifts slowly down through wide centred gaps, scores, then crashes. No tap timing needed.
    static let uiTest = GameConfig(
        gravity: 60, flapSpeed: 0, maxFallSpeed: 800, scrollSpeed: 400,
        gapHeight: 600, pillarSpacing: 230, gapCenterRange: 0.5...0.5, rampEvery: 0)

    private func level(_ score: Int) -> Double {
        rampEvery > 0 ? Double(score / rampEvery) : 0
    }

    func speedFactor(forScore score: Int) -> Double {
        min(1 + level(score) * rampSpeedStep, rampEvery > 0 ? maxSpeedFactor : 1)
    }

    func gapHeight(forScore score: Int) -> Double {
        rampEvery > 0 ? max(gapHeight - level(score) * rampGapStep, minGapHeight) : gapHeight
    }
}
