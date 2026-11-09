import SpriteKit
import SwiftUI

/// The game scene full screen, with the overlay for the current phase on top.
struct RootView: View {
    @State private var model = GameModel()
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            GeometryReader { geo in
                SpriteView(scene: model.scene, preferredFramesPerSecond: 120, options: [.ignoresSiblingOrder])
                    .onAppear { model.scene.fit(to: geo.size) }
                    .onChange(of: geo.size) { model.scene.fit(to: $1) }
            }
            .ignoresSafeArea()
            .accessibilityLabel("Play area")
            .accessibilityHint("Double-tap to flap")
            .accessibilityAddTraits(.allowsDirectInteraction)

            overlay
                .animation(.spring(duration: 0.45), value: model.phase)
        }
        .statusBarHidden()
        // Space bar flaps on hardware keyboards.
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onKeyPress(.space) {
            model.tap()
            return .handled
        }
        .onAppear { focused = true }
        .onChange(of: model.phase) { focused = true }
        .onChange(of: scenePhase) { if $1 != .active { model.pause() } }
    }

    @ViewBuilder private var overlay: some View {
        switch model.phase {
        case .home:
            HomeView(model: model).transition(.opacity)
        case .ready:
            ZStack {
                HUDView(model: model)
                ReadyHint()
            }
            .transition(.opacity)
        case .playing:
            HUDView(model: model)
        case .paused:
            PauseView(model: model).transition(.opacity)
        case .gameOver:
            GameOverView(model: model)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
