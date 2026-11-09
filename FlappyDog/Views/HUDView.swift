import SwiftUI

/// Live score and the pause button. Empty space lets taps fall through to the game.
struct HUDView: View {
    let model: GameModel

    var body: some View {
        ZStack(alignment: .top) {
            // Gameplay text keeps a fixed size on purpose.
            Text("\(model.score)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .shadow(color: Color(cgColor: Art.outline), radius: 0, x: 3, y: 4)
                .padding(.top, 24)
                .allowsHitTesting(false)
                .accessibilityLabel("Score \(model.score)")

            if model.phase == .playing {
                HStack {
                    Spacer()
                    Button(action: model.pause) {
                        VStack(spacing: 2) {
                            Image(systemName: "pause.fill").font(.system(size: 22, weight: .black))
                            Text("Pause").font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color(cgColor: Art.outline))
                        .frame(width: 68, height: 68)
                        .background(.white.opacity(0.9), in: .rect(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color(cgColor: Art.outline), lineWidth: 3))
                    }
                    .accessibilityLabel("Pause")
                }
                .padding(.trailing, 16)
                .padding(.top, 12)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct ReadyHint: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white)
                .shadow(color: Color(cgColor: Art.outline), radius: 0, x: 2, y: 3)
            Headline(text: "Tap to fly", size: .title)
        }
        .padding(.bottom, 170)
        .allowsHitTesting(false)
    }
}
