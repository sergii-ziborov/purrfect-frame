import SwiftUI

struct CameraPlayView: View {
    @Environment(AppModel.self) private var model
    @State private var flash = false
    @State private var shutterPressed = false

    var body: some View {
        ZStack {
            Palette.cameraChrome.ignoresSafeArea()

            if let session = model.session {
                TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: session.freeze != nil)) { context in
                    let poses = session.poses(at: context.date)
                    let elapsed = session.elapsed(at: context.date)
                    let hint = model.progress.hintFlashEnabled && session.timeline.isDeclaredSuccessWindow(elapsed)

                    ZStack(alignment: .top) {
                        StageView(
                            world: session.context.world,
                            poses: poses,
                            showChrome: true,
                            hintActive: hint,
                            levelIndex: session.context.levelIndex
                        )
                        .ignoresSafeArea()
                        .id("live-stage-\(session.context.world.rawValue)-\(session.context.levelIndex)")

                        VStack(spacing: 0) {
                            topBar(session: session)
                            Spacer(minLength: 0)
                            controls(session: session, now: context.date)
                        }
                    }
                }
            }
        }
        .statusBarHidden()
        .overlay {
            if flash {
                Color.white.opacity(0.78).ignoresSafeArea()
                    .transition(.opacity)
            }
        }
    }

    private func topBar(session: RoundSession) -> some View {
        HStack(spacing: 12) {
            Button {
                model.goHome()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.black.opacity(0.35), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")

            missionBanner(session.context.level.mission, cast: session.timeline.cast)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    private func missionBanner(_ mission: Mission, cast: [CharacterID]) -> some View {
        HStack(spacing: 10) {
            HStack(spacing: -6) {
                ForEach(cast) { id in
                    CreatureView(id: id, pose: .cameraReady)
                        .scaleEffect(0.18)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .background(Circle().fill(Color.white.opacity(0.92)))
                }
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(mission.prompt.uppercased())
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(mission.hint)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(Palette.inkSoft)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Palette.cream.opacity(0.94), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityIdentifier("mission-banner")
    }

    private func controls(session: RoundSession, now: Date) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(session.context.isDaily ? "DAILY" : "LEVEL \(session.context.levelIndex + 1)")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text(session.context.world.title.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 28)

            HStack(alignment: .center) {
                galleryThumb
                    .frame(width: 52)

                Spacer()

                Button {
                    shoot(session: session, now: now)
                } label: {
                    ZStack {
                        Circle()
                            .stroke(.white, lineWidth: 5)
                            .frame(width: 84, height: 84)
                        Circle()
                            .fill(.white)
                            .frame(width: shutterPressed ? 58 : 68, height: shutterPressed ? 58 : 68)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Shutter")
                .accessibilityIdentifier("shutter-button")
                .disabled(session.freeze != nil)

                Spacer()

                Color.clear.frame(width: 52, height: 52)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 18)
        }
        .padding(.top, 16)
        .background {
            LinearGradient(
                colors: [.clear, Palette.cameraChrome.opacity(0.75), Palette.cameraChrome],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private var galleryThumb: some View {
        Group {
            if let photo = model.photos.first, let image = model.image(for: photo) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.white.opacity(0.35), lineWidth: 1)
        }
        .onTapGesture { model.screen = .collection }
    }

    private func shoot(session: RoundSession, now: Date) {
        shutterPressed = true
        Feedback.shutter(sound: model.progress.soundEnabled, haptics: model.progress.hapticsEnabled)
        let freeze = session.freeze(at: now)
        withAnimation(.easeOut(duration: 0.08)) { flash = true }

        let size = CGSize(width: 900, height: 1200)
        let captureView = StageView(
            world: session.context.world,
            poses: freeze.poses,
            showChrome: false,
            hintActive: false,
            levelIndex: session.context.levelIndex,
            canvasSize: size
        )
        .frame(width: size.width, height: size.height)

        let renderer = ImageRenderer(content: captureView)
        renderer.proposedSize = ProposedViewSize(width: size.width, height: size.height)
        renderer.scale = 1
        let image = renderer.uiImage ?? UIImage()

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(120))
            withAnimation(.easeOut(duration: 0.18)) { flash = false }
            shutterPressed = false
            model.capture(image: image, evaluation: freeze.evaluation)
        }
    }
}
