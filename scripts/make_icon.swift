// Renders the app icon from the game's own art.
// swiftc -parse-as-library FlappyDog/Game/Art.swift scripts/make_icon.swift -o /tmp/make_icon && /tmp/make_icon
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

@main
struct MakeIcon {
    static func main() {
        let url = URL(fileURLWithPath: "FlappyDog/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
        let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, Art.appIcon(), nil)
        precondition(CGImageDestinationFinalize(dest), "could not write \(url.path)")
        print("wrote \(url.path)")
    }
}
