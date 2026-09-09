import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmReset = false

    var body: some View {
        @Bindable var model = model
        PFScreen(title: "Settings", onBack: { model.screen = .home }) {
            List {
                Section("Feel") {
                    Toggle("Haptics", isOn: $model.progress.hapticsEnabled)
                    Toggle("Shutter sound", isOn: $model.progress.soundEnabled)
                    Toggle("Green corners on NOW", isOn: $model.progress.hintFlashEnabled)
                }

                Section {
                    Text("A big NOW! pops up when it’s a good time to tap. Turn on green corners if you want extra help.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Section("Progress") {
                    Button("Reset progress", role: .destructive) {
                        confirmReset = true
                    }
                }

                Section("About") {
                    Button {
                        model.screen = .about
                    } label: {
                        HStack {
                            Text("About Purrfect Frame")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    LabeledContent("Version", value: "1.0.0")
                }
            }
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
