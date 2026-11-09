import SwiftUI

struct HomeView: View {
    let model: GameModel
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(maxHeight: 60)
            Headline(text: "Flappy Dog")
                .font(.system(size: 52, weight: .black, design: .rounded))
            Text("Best: \(model.best)")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(Color(cgColor: Art.outline))
                .padding(.horizontal, 18).padding(.vertical, 6)
                .background(.white.opacity(0.85), in: .capsule)
            Spacer()
            VStack(spacing: 14) {
                Button("Play") { model.play() }
                    .buttonStyle(.big)
                Button { showSettings = true } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .buttonStyle(.bigSecondary)
            }
            .frame(maxWidth: 420)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showSettings, onDismiss: model.refreshBest) {
            SettingsView()
        }
    }
}
