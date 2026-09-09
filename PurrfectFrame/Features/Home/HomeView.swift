import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        let next = LevelCatalog.nextPlayable(progress: model.progress)
        let level = LevelCatalog.level(world: next.world, index: next.index)

        Palette.cream
            .ignoresSafeArea()
            .overlay {
                Image("CafeBackground")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.14)
                    .allowsHitTesting(false)
            }
            .clipped()
            .ignoresSafeArea()
            .overlay {
                GeometryReader { geo in
                    let playHeight = min(geo.size.height * 0.46, 300)
                    VStack(spacing: 12) {
                        header
                        playCard(level: level)
                            .frame(height: playHeight)
                        Spacer(minLength: 8)
                        dailyRow
                        destRow
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 18)
                    .frame(maxWidth: sizeClass == .regular ? 560 : .infinity)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                }
            }
            .clipped()
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image("BrandMark")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text("Purrfect Frame")
                    .font(.pfDisplay(20))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(model.progress.photographerRank)
                    .font(.pfBody(12))
                    .foregroundStyle(Palette.wood)
            }
            Spacer(minLength: 8)
            Button {
                model.screen = .ratings
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Palette.gold)
                    Text("\(model.progress.totalStars)")
                        .font(.pfBody(14))
                        .foregroundStyle(Palette.ink)
                }
                .padding(.horizontal, 10)
                .frame(height: 36)
                .background(Color.white.opacity(0.9), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Ratings")
            .accessibilityIdentifier("Ratings")

            Button {
                model.screen = .settings
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.9), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
            .accessibilityIdentifier("Settings")
        }
    }

    private func playCard(level: LevelDefinition) -> some View {
        Button {
            model.playTapped()
        } label: {
            VStack(spacing: 0) {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                    let now = context.date.timeIntervalSinceReferenceDate
                    GeometryReader { geo in
                        let animal = min(geo.size.width / 560, geo.size.height / 340, 0.52)
                        ZStack(alignment: .bottom) {
                            Image(level.world.background(for: level.index))
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                                .clipped()

                            LinearGradient(
                                colors: [.clear, .clear, .black.opacity(0.55)],
                                startPoint: .top,
                                endPoint: .bottom
                            )

                            HStack(alignment: .bottom, spacing: -8) {
                                ForEach(Array(level.cast.enumerated()), id: \.element.id) { index, id in
                                    CreatureView(
                                        id: id,
                                        pose: IdleMotion.pose(id: id, at: now, index: index)
                                    )
                                    .scaleEffect(animal)
                                    .frame(width: 200 * animal, height: 230 * animal)
                                    .clipped()
                                }
                            }
                            .padding(.bottom, 52)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(level.world.title.uppercased())
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .tracking(1.1)
                                    .foregroundStyle(.white.opacity(0.82))
                                Text("Level \(level.index + 1)")
                                    .font(.pfDisplay(22))
                                    .foregroundStyle(.white)
                                Text(level.mission.prompt)
                                    .font(.pfBody(14))
                                    .foregroundStyle(.white.opacity(0.94))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .clipped()
                    }
                }
                .clipped()

                HStack {
                    Label("Play", systemImage: "camera.fill")
                        .font(.pfBody(17))
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Palette.sky)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .clipped()
            .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("play-button")
        .accessibilityLabel("Play")
    }

    private var destRow: some View {
        HStack(spacing: 10) {
            dest("Worlds", icon: "globe", screen: .worlds)
            dest("Collection", icon: "photo.on.rectangle", screen: .collection)
            dest("Ratings", icon: "star.fill", screen: .ratings)
        }
    }

    private func dest(_ title: String, icon: String, screen: Screen) -> some View {
        Button {
            model.screen = screen
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.pfBody(12))
            }
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(title)
        .accessibilityLabel(title)
    }

    private var dailyRow: some View {
        Button {
            model.playDaily()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                Text("Today’s challenge")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .font(.pfBody(15))
            .foregroundStyle(Palette.wood)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("daily-button")
    }
}
