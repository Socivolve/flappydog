import SwiftUI

/// Large, labelled buttons: 88 pt for main actions, 60 pt for the rest.
struct BigButtonStyle: ButtonStyle {
    var primary = true
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(primary ? .title : .title3, design: .rounded).weight(.heavy))
            .foregroundStyle(primary ? .white : Color(cgColor: Art.outline))
            .frame(maxWidth: .infinity, minHeight: primary ? 88 : 60)
            .padding(.horizontal, 16)
            .background {
                // Shadow on the shape only, so the label stays crisp.
                RoundedRectangle(cornerRadius: 24)
                    .fill(primary ? Color(red: 1, green: 0.52, blue: 0.2) : .white)
                    .shadow(color: .black.opacity(0.2), radius: 0, y: configuration.isPressed ? 1 : 5)
            }
            .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(Color(cgColor: Art.outline), lineWidth: 3))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(isEnabled ? 1 : 0.6)
            .contentShape(.rect)
    }
}

extension ButtonStyle where Self == BigButtonStyle {
    static var big: BigButtonStyle { BigButtonStyle() }
    static var bigSecondary: BigButtonStyle { BigButtonStyle(primary: false) }
}

/// The white card the menus sit on.
struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 16) { content }
            .padding(24)
            .frame(maxWidth: 420)
            .background(Color(cgColor: Art.bone), in: .rect(cornerRadius: 32))
            .overlay(RoundedRectangle(cornerRadius: 32).strokeBorder(Color(cgColor: Art.outline), lineWidth: 4))
            .padding(.horizontal, 20)
    }
}

/// Big outlined title text used on top of the sky.
struct Headline: View {
    var text: String
    var size: Font.TextStyle = .largeTitle

    var body: some View {
        Text(text)
            .font(.system(size, design: .rounded).weight(.black))
            .foregroundStyle(.white)
            .shadow(color: Color(cgColor: Art.outline), radius: 0, x: 2, y: 3)
            .multilineTextAlignment(.center)
    }
}
