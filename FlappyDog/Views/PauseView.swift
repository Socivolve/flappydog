import SwiftUI

struct PauseView: View {
    let model: GameModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            Card {
                Text("Paused")
                    .font(.system(.largeTitle, design: .rounded).weight(.black))
                    .foregroundStyle(Color(cgColor: Art.outline))
                Button("Resume", action: model.resume).buttonStyle(.big)
                Button("Home", action: model.goHome).buttonStyle(.bigSecondary)
            }
        }
    }
}
