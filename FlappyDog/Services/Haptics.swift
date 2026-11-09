import UIKit

/// Flap tap, score tick, crash thud. Off when Haptics is off in Settings.
@MainActor
final class Haptics {
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)

    func flap() { fire(light, 0.7) }
    func score() { fire(soft, 0.6) }
    func crash() { fire(heavy, 1) }

    private func fire(_ generator: UIImpactFeedbackGenerator, _ intensity: CGFloat) {
        guard UserDefaults.standard.bool(forKey: SettingsKey.haptics) else { return }
        generator.impactOccurred(intensity: intensity)
    }
}
