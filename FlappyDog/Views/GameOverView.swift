import SwiftUI

struct GameOverView: View {
    let model: GameModel

    var body: some View {
        VStack {
            Spacer()
            Card {
                Text("Game Over")
                    .font(.system(.largeTitle, design: .rounded).weight(.black))
                    .foregroundStyle(Color(cgColor: Art.outline))
                if model.isNewBest {
                    Label("New best!", systemImage: "star.fill")
                        .font(.system(.headline, design: .rounded).weight(.heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(Color(red: 0.95, green: 0.3, blue: 0.4), in: .capsule)
                }
                HStack(spacing: 32) {
                    stat("Score", model.score, id: "finalScore")
                    stat("Best", model.best, id: "bestScore")
                }
                Button("Play again", action: model.play)
                    .buttonStyle(.big)
                    .disabled(!model.canRestart)
                Button("Home", action: model.goHome)
                    .buttonStyle(.bigSecondary)
            }
            .padding(.bottom, 24)
        }
    }

    private func stat(_ title: String, _ value: Int, id: String) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color(cgColor: Art.outline).opacity(0.7))
            Text("\(value)")
                .font(.system(.largeTitle, design: .rounded).weight(.black))
                .foregroundStyle(Color(cgColor: Art.outline))
                .accessibilityIdentifier(id)
        }
        .accessibilityElement(children: .contain)
    }
}
