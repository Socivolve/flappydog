import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKey.sound) private var sound = true
    @AppStorage(SettingsKey.haptics) private var haptics = true
    @AppStorage(SettingsKey.relaxed) private var relaxed = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    toggle("Sound", "speaker.wave.2.fill", $sound)
                    toggle("Haptics", "iphone.radiowaves.left.and.right", $haptics)
                }
                Section {
                    toggle("Relaxed mode", "tortoise.fill", $relaxed)
                } footer: {
                    Text("Wider gaps and a slower pace. Relaxed mode keeps its own best score.")
                }
            }
            .font(.system(.title3, design: .rounded).weight(.semibold))
            .navigationTitle("Settings")
            .safeAreaInset(edge: .bottom) {
                Button("Done") { dismiss() }
                    .buttonStyle(.big)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }
        }
    }

    private func toggle(_ title: String, _ icon: String, _ isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) { Label(title, systemImage: icon) }
            .frame(minHeight: 60)
    }
}
