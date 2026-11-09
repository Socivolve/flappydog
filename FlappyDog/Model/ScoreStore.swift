import Foundation

/// Best scores on this device. Normal and relaxed mode are kept apart.
struct ScoreStore {
    var defaults: UserDefaults = .standard

    func best(relaxed: Bool) -> Int {
        defaults.integer(forKey: key(relaxed))
    }

    /// Saves the score if it beats the best one. Returns true for a new best.
    @discardableResult
    func record(_ score: Int, relaxed: Bool) -> Bool {
        guard score > best(relaxed: relaxed) else { return false }
        defaults.set(score, forKey: key(relaxed))
        return true
    }

    private func key(_ relaxed: Bool) -> String {
        relaxed ? "best.relaxed" : "best.normal"
    }
}

/// UserDefaults keys for the Settings toggles.
enum SettingsKey {
    static let sound = "sound"
    static let haptics = "haptics"
    static let relaxed = "relaxed"
}
