import SpriteKit
import UIKit

/// Draws what `GameWorld` says and passes taps on. Holds no game rules.
final class GameScene: SKScene {
    weak var model: GameModel?

    /// Everything that shakes on a crash.
    private let content = SKNode()
    /// The fixed 390 × 844 world, centred in the scene.
    private let worldNode = SKNode()
    private let sky = SKSpriteNode(texture: SKTexture(cgImage: Art.sky()))
    private let clouds = TiledLayer(texture: SKTexture(cgImage: Art.clouds()), size: Art.cloudsSize)
    private let hills = TiledLayer(texture: SKTexture(cgImage: Art.hills()), size: Art.hillsSize)
    private let ground = TiledLayer(texture: SKTexture(cgImage: Art.ground()), size: Art.groundTile)
    private let dog = DogNode()
    private let flash = SKSpriteNode(color: .white, size: .zero)
    private var pillarNodes: [PillarNode] = []

    private var lastTime: TimeInterval?
    private var scroll = 0.0
    private var hoverTime = 0.0

    override init() {
        super.init(size: CGSize(width: GameWorld.width, height: GameWorld.height))
        scaleMode = .aspectFit
        anchorPoint = .zero
        backgroundColor = UIColor(cgColor: Art.skyTop)

        sky.anchorPoint = .zero
        sky.zPosition = -100
        clouds.zPosition = -90
        hills.zPosition = -80
        ground.zPosition = 20
        dog.zPosition = 10
        flash.anchorPoint = .zero
        flash.zPosition = 100
        flash.alpha = 0

        addChild(sky)
        addChild(content)
        addChild(flash)
        [clouds, hills, worldNode, ground].forEach(content.addChild)
        worldNode.addChild(dog)
        dog.position = CGPoint(x: GameWorld.dogX, y: GameWorld.playCenter)
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    /// Extra width on each side of the world on wide screens.
    var spawnMargin: Double { max(0, (size.width - GameWorld.width) / 2) }

    /// Gives the scene the screen's aspect ratio while keeping the whole 390 × 844 world visible.
    func fit(to view: CGSize) {
        guard view.width > 0, view.height > 0 else { return }
        let aspect = view.width / view.height
        size = CGSize(width: max(GameWorld.width, GameWorld.height * aspect),
                      height: max(GameWorld.height, GameWorld.width / aspect))
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layout()
    }

    private func layout() {
        let origin = CGPoint(x: (size.width - GameWorld.width) / 2, y: (size.height - GameWorld.height) / 2)
        let groundTop = origin.y + GameWorld.groundHeight
        worldNode.position = origin
        sky.size = size
        flash.size = size
        ground.position = CGPoint(x: 0, y: groundTop - Art.groundTile.height)
        hills.position = CGPoint(x: 0, y: groundTop - 4)
        clouds.position = CGPoint(x: 0, y: origin.y + GameWorld.height - Art.cloudsSize.height - 40)
        [clouds, hills, ground].forEach { $0.fill(width: size.width) }
    }

    // MARK: Events from the model

    func reset() {
        content.removeAllActions()
        content.position = .zero
        dog.resetPose()
        pillarNodes.forEach { $0.isHidden = true }
    }

    func dogFlapped() { dog.flapped() }

    func crashEffects() {
        flash.removeAllActions()
        flash.alpha = 0.85
        flash.run(.fadeOut(withDuration: 0.25))
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let offsets: [CGFloat] = [10, -16, 12, -8, 2]
        content.run(.sequence(offsets.map { .moveBy(x: $0, y: 0, duration: 0.035) }))
    }

    // MARK: Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        model?.tap()
    }

    // MARK: Frame

    override func update(_ currentTime: TimeInterval) {
        let dt = min(lastTime.map { currentTime - $0 } ?? 0, 0.1)
        lastTime = currentTime
        guard let model else { return }
        model.tick(dt)
        let world = model.world
        let phase = model.phase

        let speed: Double = switch phase {
        case .home, .ready: 60
        case .playing where !world.crashed: world.config.scrollSpeed * world.speedFactor
        default: 0
        }
        scroll += speed * dt
        let parallax = UIAccessibility.isReduceMotionEnabled ? 0.5 : 1
        ground.layout(scroll: scroll)
        hills.layout(scroll: scroll * 0.35 * parallax)
        clouds.layout(scroll: scroll * 0.12 * parallax + hoverTime * 4 * parallax)

        let hovering = phase == .home || phase == .ready
        hoverTime += dt
        if hovering {
            dog.position.y = GameWorld.playCenter + sin(hoverTime * 3.5) * 8
        } else {
            dog.position.y = world.dogY
        }
        let frozen = phase == .paused || phase == .gameOver
        dog.isPaused = frozen
        dog.update(dt: frozen ? 0 : dt, velocity: world.dogVelocity,
                   maxFall: world.config.maxFallSpeed, hovering: hovering)

        syncPillars(hovering ? [] : world.pillars)
    }

    private func syncPillars(_ pillars: [GameWorld.Pillar]) {
        while pillarNodes.count < pillars.count {
            let node = PillarNode()
            worldNode.addChild(node)
            pillarNodes.append(node)
        }
        for (i, node) in pillarNodes.enumerated() {
            node.isHidden = i >= pillars.count
            if i < pillars.count { node.place(pillars[i]) }
        }
    }
}

/// A row of identical tiles that scrolls left forever.
private final class TiledLayer: SKNode {
    private let texture: SKTexture
    private let tileSize: CGSize
    private var tiles: [SKSpriteNode] = []

    init(texture: SKTexture, size: CGSize) {
        self.texture = texture
        tileSize = size
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func fill(width: CGFloat) {
        let needed = Int((width / tileSize.width).rounded(.up)) + 1
        while tiles.count < needed {
            let tile = SKSpriteNode(texture: texture, size: tileSize)
            tile.anchorPoint = .zero
            addChild(tile)
            tiles.append(tile)
        }
    }

    func layout(scroll: Double) {
        let offset = CGFloat(scroll).truncatingRemainder(dividingBy: tileSize.width)
        for (i, tile) in tiles.enumerated() {
            tile.position.x = CGFloat(i) * tileSize.width - offset
        }
    }
}
