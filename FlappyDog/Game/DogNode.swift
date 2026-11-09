import SpriteKit

/// The winged pup: a looping 3-frame flap that speeds up after each tap, and a tilt that follows its speed.
final class DogNode: SKSpriteNode {
    private static let frames = (0..<3).map { SKTexture(cgImage: Art.dog(wing: $0)) }
    private var boost = 0.0

    init() {
        super.init(texture: Self.frames[1], color: .clear, size: Art.dogSize)
        let f = Self.frames
        run(.repeatForever(.animate(with: [f[0], f[1], f[2], f[1]], timePerFrame: 0.08)), withKey: "flap")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func flapped() { boost = 0.25 }

    /// Tilts up to +20° on a flap and down to −70° as it falls.
    func update(dt: Double, velocity: Double, maxFall: Double, hovering: Bool) {
        boost = max(0, boost - dt)
        action(forKey: "flap")?.speed = boost > 0 ? 3 : 1
        let up = 20.0 * .pi / 180, down = -70.0 * .pi / 180
        let target: Double
        if hovering {
            target = 0
        } else if velocity > -200 {
            target = up
        } else {
            target = up + (down - up) * min(1, (-velocity - 200) / max(1, maxFall - 200))
        }
        zRotation += (target - zRotation) * min(1, dt * 12)
    }

    func resetPose() {
        zRotation = 0
        boost = 0
    }
}
