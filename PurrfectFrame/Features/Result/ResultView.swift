import SwiftUI
import Photos
import StoreKit

struct ResultView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.requestReview) private var requestReview
    @State private var saveMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            if let session = model.session, let outcome = model.lastOutcome {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        Text(outcome.evaluation.title)
                            .font(.pfDisplay(32))
                            .foregroundStyle(Palette.ink)
                            .accessibilityIdentifier("result-title")

                        polaroid(outcome: outcome)

                        StarRow(stars: outcome.evaluation.stars, size: 24)

                        Text(outcome.evaluation.caption)
                            .font(.pfScript(20))
                            .foregroundStyle(Palette.wood)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        checklist(outcome.evaluation)

                        buttons(session: session, outcome: outcome)

                        if let saveMessage {
                            Text(saveMessage)
                                .font(.pfBody(13))
                                .foregroundStyle(Palette.moss)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Palette.cream.ignoresSafeArea())
        .onAppear {
            if model.consumeReviewPrompt() {
                requestReview()
            }
        }
    }

    private func polaroid(outcome: ShotOutcome) -> some View {
        VStack(spacing: 12) {
            if let image = model.image(for: outcome.photo) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            Text(outcome.evaluation.success ? "Purrfect!" : outcome.evaluation.title)
                .font(.pfBody(20))
                .foregroundStyle(Palette.ink)
                .padding(.bottom, 8)
        }
        .padding(14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 16, y: 8)
        .rotationEffect(.degrees(outcome.evaluation.success ? -1.5 : 2.2))
        .padding(.horizontal, 18)
    }

    private func checklist(_ evaluation: ShotEvaluation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(evaluation.verdicts) { verdict in
                HStack(spacing: 10) {
                    Image(systemName: rowOK(verdict, evaluation: evaluation) ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(rowOK(verdict, evaluation: evaluation) ? Palette.moss : Palette.coral)
                    Text(line(for: verdict))
                        .font(.pfBody(15))
                        .foregroundStyle(Palette.ink)
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func rowOK(_ verdict: CharacterVerdict, evaluation: ShotEvaluation) -> Bool {
        if !verdict.looking || !verdict.eyesOpen { return false }
        if verdict.covering { return false }
        if case .allStill = model.session?.context.level.mission, verdict.jumping { return false }
        if case .catchJumper(let id) = model.session?.context.level.mission, verdict.id == id {
            return verdict.jumping
        }
        return true
    }

    private func line(for verdict: CharacterVerdict) -> String {
        if verdict.covering { return "\(verdict.id.displayName) photobombed the shot" }
        if !verdict.eyesOpen { return "\(verdict.id.displayName) blinked" }
        if !verdict.looking { return "\(verdict.id.displayName) looked away" }
        if verdict.jumping { return "\(verdict.id.displayName) jumped" }
        return "\(verdict.id.displayName) looking"
    }

    private func buttons(session: RoundSession, outcome: ShotOutcome) -> some View {
        VStack(spacing: 10) {
            if outcome.evaluation.success {
                PFButton(title: "Next Level", kind: .success, icon: "arrow.right") {
                    model.nextLevel()
                }
                .accessibilityIdentifier("next-level-button")
            } else {
                PFButton(title: "Try again", kind: .play, icon: "camera.fill") {
                    model.retry()
                }
                .accessibilityIdentifier("retry-button")
            }

            HStack(spacing: 10) {
                Button {
                    saveToPhotos(outcome)
                } label: {
                    label("Save to Photos", "square.and.arrow.down")
                }
                .buttonStyle(.plain)

                ShareLink(item: model.photoStore.fileURL(for: outcome.photo)) {
                    label("Share", "square.and.arrow.up")
                }
            }

            Button("Home") { model.goHome() }
                .font(.pfBody(16))
                .foregroundStyle(Palette.inkSoft)
                .padding(.top, 4)
        }
    }

    private func label(_ title: String, _ icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.pfBody(14))
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white, in: Capsule())
    }

    private func saveToPhotos(_ outcome: ShotOutcome) {
        guard let image = model.image(for: outcome.photo) else { return }
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                Task { @MainActor in saveMessage = "Photos access was declined." }
                return
            }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            Task { @MainActor in saveMessage = "Saved to Photos." }
        }
    }
}

extension CharacterVerdict: Identifiable {}
