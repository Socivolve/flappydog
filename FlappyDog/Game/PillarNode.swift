import SpriteKit

/// A pair of bone pillars around one gap. The top bone is the bottom one flipped.
final class PillarNode: SKNode {
    private static let texture = SKTexture(cgImage: Art.bonePillar())
    private let bottom = SKSpriteNode(texture: PillarNode.texture, size: Art.boneSize)
    private let top = SKSpriteNode(texture: PillarNode.texture, size: Art.boneSize)

    override init() {
        super.init()
        for bone in [bottom, top] {
            bone.anchorPoint = CGPoint(x: 0.5, y: 1)
            addChild(bone)
        }
        top.yScale = -1
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func place(_ pillar: GameWorld.Pillar) {
        position.x = pillar.x
        bottom.position.y = pillar.gapBottom
        top.position.y = pillar.gapTop
    }
}
