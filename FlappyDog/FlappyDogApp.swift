import SwiftUI

@main
struct FlappyDogApp: App {
    init() {
        UserDefaults.standard.register(defaults: [SettingsKey.sound: true, SettingsKey.haptics: true])
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
