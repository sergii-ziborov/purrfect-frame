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
                    let nowHint = session.timeline.isDeclaredSuccessWindow(elapsed)

                    VStack(spacing: 0) {
                        ZStack(alignment: .top) {
                            StageView(
                                world: session.context.world,
                                poses: poses,
                                showChrome: true,
                                hintActive: nowHint && model.progress.hintFlashEnabled,
                                levelIndex: session.context.levelIndex
                            )
                            .clipped()
                            .id("live-stage-\(session.context.world.rawValue)-\(session.context.levelIndex)")

                            topBar(session: session)
                        }
                        .frame(maxHeight: .infinity)
                        .clipped()

                        controls(session: session, now: context.date, nowHint: nowHint)
                    }
                    .clipped()
                }
            }
        }
        .statusBarHidden()
        .clipped()
        .overlay {
            if flash {
                Color.white.opacity(0.78).ignoresSafeArea()
                    .transition(.opacity)
            }
        }
    }

    private func topBar(session: RoundSession) -> some View {
        HStack(alignment: .top, spacing: 12) {
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

            missionBanner(session.context.level.mission)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.top, 10)
    }

    private func missionBanner(_ mission: Mission) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(mission.prompt)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(mission.hint)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Palette.inkSoft)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.cream.opacity(0.94), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityIdentifier("mission-banner")
    }

    private func controls(session: RoundSession, now: Date, nowHint: Bool) -> some View {
        let pulse = nowHint ? 1 + 0.06 * sin(session.elapsed(at: now) * 8) : 1.0
        return VStack(spacing: 10) {
            if nowHint {
                Text("NOW!")
                    .font(.pfDisplay(22))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .background(Palette.moss, in: Capsule())
                    .scaleEffect(pulse)
                    .accessibilityIdentifier("now-hint")
            }

            HStack {
                Text(session.context.isDaily ? "TODAY" : "LEVEL \(session.context.levelIndex + 1)")
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
                            .stroke(nowHint ? Palette.moss : .white, lineWidth: 5)
                            .frame(width: 78, height: 78)
                        Circle()
                            .fill(.white)
                            .frame(width: shutterPressed ? 52 : 62, height: shutterPressed ? 52 : 62)
                    }
                    .scaleEffect(pulse)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Shutter")
                .accessibilityIdentifier("shutter-button")
                .disabled(session.freeze != nil)
                Spacer()
                Color.clear.frame(width: 52, height: 52)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 12)
        }
        .padding(.top, 10)
        .background(Palette.cameraChrome)
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
