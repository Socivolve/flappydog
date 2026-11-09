import CoreGraphics
import Foundation

/// All game art, drawn in code with plain CoreGraphics (origin bottom-left, like SpriteKit).
/// Pure CoreGraphics so `scripts/make_icon.swift` can reuse it on the Mac.
enum Art {
    static let dogSize = CGSize(width: 72, height: 60)
    static let boneSize = CGSize(width: 84, height: 900)
    static let groundTile = CGSize(width: 48, height: 420)
    static let hillsSize = CGSize(width: 390, height: 190)
    static let cloudsSize = CGSize(width: 390, height: 260)

    static let scale: CGFloat = 3

    // MARK: Palette

    static let outline = rgb(0x4A, 0x32, 0x22)
    static let fur = rgb(0xE0, 0xA8, 0x6A)
    static let furLight = rgb(0xF6, 0xDD, 0xB8)
    static let ear = rgb(0x8B, 0x56, 0x2E)
    static let wing = rgb(0xFF, 0xFF, 0xFF)
    static let wingShade = rgb(0xCF, 0xE6, 0xF5)
    static let bone = rgb(0xF6, 0xEE, 0xD8)
    static let boneShade = rgb(0xE2, 0xD3, 0xAE)
    static let skyTop = rgb(0x7C, 0xC8, 0xF8)
    static let skyBottom = rgb(0xDD, 0xF3, 0xFF)

    static func rgb(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> CGColor {
        CGColor(srgbRed: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a)
    }

    /// Renders `size` points at `scale` into an image.
    static func image(_ size: CGSize, scale: CGFloat = scale, opaque: Bool = false, _ draw: (CGContext) -> Void) -> CGImage {
        let ctx = CGContext(
            data: nil, width: Int(size.width * scale), height: Int(size.height * scale),
            bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: opaque ? CGImageAlphaInfo.noneSkipLast.rawValue : CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.scaleBy(x: scale, y: scale)
        draw(ctx)
        return ctx.makeImage()!
    }

    // MARK: Dog

    /// Wing frame 0 = up, 1 = middle, 2 = down.
    static func dog(wing frame: Int, scale: CGFloat = scale) -> CGImage {
        image(dogSize, scale: scale) { drawDog(in: $0, wing: frame) }
    }

    static func drawDog(in c: CGContext, wing frame: Int) {
        c.setLineWidth(2)
        c.setStrokeColor(outline)
        c.setLineJoin(.round)

        // Tail
        c.setLineCap(.round)
        c.setLineWidth(6)
        c.move(to: CGPoint(x: 15, y: 30))
        c.addQuadCurve(to: CGPoint(x: 5, y: 42), control: CGPoint(x: 4, y: 30))
        c.strokePath()
        c.setLineWidth(3)
        c.setStrokeColor(fur)
        c.move(to: CGPoint(x: 15, y: 30))
        c.addQuadCurve(to: CGPoint(x: 5, y: 42), control: CGPoint(x: 4, y: 30))
        c.strokePath()
        c.setStrokeColor(outline)
        c.setLineWidth(2)

        // Paws
        for x in [24.0, 40.0] {
            blob(c, CGRect(x: x, y: 6, width: 11, height: 9), fill: furLight)
        }
        // Body and belly
        blob(c, CGRect(x: 12, y: 10, width: 44, height: 36), fill: fur)
        c.setFillColor(furLight)
        c.fillEllipse(in: CGRect(x: 24, y: 12, width: 24, height: 16))
        // Head
        blob(c, CGRect(x: 37, y: 21, width: 30, height: 30), fill: fur)
        // Floppy ear
        c.saveGState()
        c.translateBy(x: 45, y: 46)
        c.rotate(by: 0.5)
        blob(c, CGRect(x: -6, y: -17, width: 12, height: 20), fill: ear)
        c.restoreGState()
        // Muzzle, nose, eye
        blob(c, CGRect(x: 54, y: 25, width: 16, height: 12), fill: furLight)
        c.setFillColor(outline)
        c.fillEllipse(in: CGRect(x: 65, y: 32, width: 6, height: 5))
        c.fillEllipse(in: CGRect(x: 52, y: 38, width: 5.5, height: 6))
        c.setFillColor(rgb(255, 255, 255))
        c.fillEllipse(in: CGRect(x: 54, y: 41.5, width: 2, height: 2))
        // Smile
        c.setLineWidth(1.5)
        c.move(to: CGPoint(x: 60, y: 29))
        c.addQuadCurve(to: CGPoint(x: 66, y: 29), control: CGPoint(x: 63, y: 26))
        c.strokePath()

        // Feathered wing, hinged at the shoulder
        // Three feathers fan backwards from the shoulder; the frame sets how high the fan points.
        let base: CGFloat = [-1.0, -0.3, 0.45][max(0, min(2, frame))]
        c.setLineWidth(1.8)
        for (i, length) in [32.0, 27.0, 21.0].enumerated().reversed() {
            c.saveGState()
            c.translateBy(x: 32, y: 34)
            c.rotate(by: base + CGFloat(i) * 0.38)
            blob(c, CGRect(x: -length, y: -5.5, width: length + 6, height: 11), fill: i == 0 ? wing : wingShade)
            c.restoreGState()
        }
        blob(c, CGRect(x: 25, y: 28, width: 15, height: 12), fill: wing)
    }

    /// Filled and outlined ellipse.
    private static func blob(_ c: CGContext, _ rect: CGRect, fill: CGColor) {
        c.setFillColor(fill)
        c.addEllipse(in: rect)
        c.drawPath(using: .fillStroke)
    }

    // MARK: Bone pillar

    /// A bone pillar with its knob at the top. The top pillar is the same image flipped.
    static func bonePillar() -> CGImage {
        image(boneSize, scale: 2) { c in
            let w = boneSize.width, h = boneSize.height, r: CGFloat = 19
            let shaft = CGRect(x: 9, y: 0, width: w - 18, height: h - r)
            let knobs = [CGRect(x: 2, y: h - 2 * r - 1, width: 2 * r, height: 2 * r),
                         CGRect(x: w - 2 - 2 * r, y: h - 2 * r - 1, width: 2 * r, height: 2 * r)]
            let shape = CGMutablePath()
            shape.addRect(shaft)
            knobs.forEach { shape.addEllipse(in: $0) }
            // Thick outline first, then the fill on top hides the inner edges.
            c.addPath(shape)
            c.setStrokeColor(outline)
            c.setLineWidth(6)
            c.strokePath()
            c.addPath(shape)
            c.setFillColor(bone)
            c.fillPath()
            // Shading stripe and a gap in the stripe near the knob for shape.
            c.setFillColor(boneShade)
            c.fill(CGRect(x: w - 28, y: 0, width: 10, height: h - 2 * r - 6))
            c.setFillColor(rgb(255, 255, 255, 0.7))
            c.fill(CGRect(x: 20, y: 0, width: 6, height: h - 2 * r - 6))
        }
    }

    // MARK: Park in the sky

    static func sky() -> CGImage {
        image(CGSize(width: 4, height: 256), scale: 1, opaque: true) { c in
            let gradient = CGGradient(colorsSpace: nil, colors: [skyBottom, skyTop] as CFArray, locations: [0, 1])!
            c.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: 256), options: [])
        }
    }

    /// Ground tile: grass on top, striped soil below. Tiles seamlessly.
    static func ground() -> CGImage {
        image(groundTile, scale: 2) { c in
            let w = groundTile.width, h = groundTile.height
            c.setFillColor(rgb(0xC8, 0x8C, 0x52))
            c.fill(CGRect(origin: .zero, size: groundTile))
            c.setFillColor(rgb(0xB3, 0x77, 0x42))
            for x in stride(from: -w, through: w, by: 24) {
                c.move(to: CGPoint(x: x, y: 0))
                c.addLine(to: CGPoint(x: x + 12, y: 0))
                c.addLine(to: CGPoint(x: x + 12 + h, y: h))
                c.addLine(to: CGPoint(x: x + h, y: h))
                c.fillPath()
            }
            c.setFillColor(outline)
            c.fill(CGRect(x: 0, y: h - 26, width: w, height: 3))
            c.setFillColor(rgb(0x5C, 0xB8, 0x48))
            c.fill(CGRect(x: 0, y: h - 23, width: w, height: 23))
            c.setFillColor(rgb(0x7F, 0xD1, 0x5E))
            c.fill(CGRect(x: 0, y: h - 7, width: w, height: 7))
            c.setFillColor(rgb(0x47, 0x9A, 0x37))
            for x in stride(from: 0.0, to: w, by: 12) {
                c.move(to: CGPoint(x: x, y: h - 23))
                c.addLine(to: CGPoint(x: x + 4, y: h - 12))
                c.addLine(to: CGPoint(x: x + 8, y: h - 23))
                c.fillPath()
            }
        }
    }

    /// Two rows of rolling hills. Whole sine periods, so they tile seamlessly.
    static func hills() -> CGImage {
        image(hillsSize, scale: 2) { c in
            func hill(base: CGFloat, amp: CGFloat, periods: CGFloat, phase: CGFloat, color: CGColor) {
                let w = hillsSize.width
                c.move(to: .zero)
                for x in stride(from: 0, through: w, by: 2) {
                    c.addLine(to: CGPoint(x: x, y: base + amp * sin(x / w * .pi * 2 * periods + phase)))
                }
                c.addLine(to: CGPoint(x: w, y: 0))
                c.setFillColor(color)
                c.fillPath()
            }
            hill(base: 130, amp: 34, periods: 2, phase: 0.6, color: rgb(0xB4, 0xE0, 0x96))
            hill(base: 80, amp: 28, periods: 3, phase: 2.0, color: rgb(0x8C, 0xCD, 0x70))
        }
    }

    static func clouds() -> CGImage {
        image(cloudsSize, scale: 2) { c in
            func cloud(_ x: CGFloat, _ y: CGFloat, _ s: CGFloat) {
                let puffs: [(CGFloat, CGFloat, CGFloat)] = [(0, 0, 22), (22, 10, 28), (50, 2, 22), (24, -6, 20)]
                c.setFillColor(rgb(0xB9, 0xDD, 0xF2))
                for (dx, dy, r) in puffs { c.fillEllipse(in: CGRect(x: x + dx * s - r * s, y: y + (dy - 4) * s - r * s, width: 2 * r * s, height: 2 * r * s)) }
                c.setFillColor(rgb(255, 255, 255))
                for (dx, dy, r) in puffs { c.fillEllipse(in: CGRect(x: x + dx * s - r * s, y: y + dy * s - r * s, width: 2 * r * s, height: 2 * r * s)) }
            }
            cloud(60, 190, 1.0)
            cloud(250, 120, 0.8)
            cloud(170, 225, 0.55)
        }
    }

    // MARK: App icon

    static func appIcon() -> CGImage {
        let size = CGSize(width: 1024, height: 1024)
        return image(size, scale: 1, opaque: true) { c in
            let gradient = CGGradient(colorsSpace: nil, colors: [skyBottom, skyTop] as CFArray, locations: [0, 1])!
            c.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: 1024), options: [])
            c.saveGState()
            c.scaleBy(x: 1024 / hillsSize.width, y: 1024 / hillsSize.width * 0.9)
            c.draw(hills(), in: CGRect(origin: .zero, size: hillsSize))
            c.restoreGState()
            c.translateBy(x: 512, y: 540)
            c.rotate(by: 0.15)
            c.scaleBy(x: 11, y: 11)
            c.translateBy(x: -dogSize.width / 2 - 4, y: -dogSize.height / 2)
            drawDog(in: c, wing: 0)
        }
    }
}
