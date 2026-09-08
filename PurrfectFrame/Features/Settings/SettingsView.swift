import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmReset = false

    var body: some View {
        @Bindable var model = model
        ZStack {
            Palette.cream.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button {
                        model.screen = .home
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Palette.ink)
                    }
                    .accessibilityIdentifier("back-button")
                    Spacer()
                    Text("Settings")
                        .font(.pfDisplay(22))
                    Spacer()
                    Color.clear.frame(width: 18)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                List {
                    Section("Feel") {
                        Toggle("Haptics", isOn: $model.progress.hapticsEnabled)
                        Toggle("Shutter sound", isOn: $model.progress.soundEnabled)
                        Toggle("Practice hint", isOn: $model.progress.hintFlashEnabled)
                    }

                    Section {
                        Text("When Practice hint is on, the viewfinder turns green during the guaranteed good window. Off by default — the fun is catching it yourself.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }

                    Section("Progress") {
                        Button("Reset progress", role: .destructive) {
                            confirmReset = true
                        }
                    }

                    Section("About") {
                        LabeledContent("Version", value: "1.0.0")
                        Text("Purrfect Frame is a one-tap group photo game. Four characters, one assignment, a shutter that keeps the exact moment you pressed it — including the misses worth showing someone.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .onChange(of: model.progress.hapticsEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.soundEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.hintFlashEnabled) { _, _ in model.saveProgress() }
        .confirmationDialog("Reset all stars and unlocks?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { model.resetProgress() }
            Button("Cancel", role: .cancel) {}
        }
    }
}
