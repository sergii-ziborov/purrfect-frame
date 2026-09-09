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
                VStack(spacing: 12) {
                    header
                    playCard(level: level)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    dailyRow
                    destRow
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .frame(maxWidth: sizeClass == .regular ? 560 : .infinity)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        let maxCatW = (geo.size.width - 28) / 4
                        let maxCatH = geo.size.height * 0.46
                        let animal = min(maxCatW / 200, maxCatH / 230)
                        ZStack(alignment: .bottom) {
                            Color.clear
                                .overlay {
                                    Image(level.world.backgroundAsset)
                                        .resizable()
                                        .scaledToFill()
                                }
                                .clipped()

                            HStack(alignment: .bottom, spacing: 0) {
                                ForEach(Array(level.cast.enumerated()), id: \.element.id) { index, id in
                                    CreatureView(
                                        id: id,
                                        pose: IdleMotion.pose(id: id, at: now, index: index)
                                    )
                                    .scaleEffect(animal)
                                    .frame(width: 200 * animal, height: 230 * animal)
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(level.world.title)  ·  Level \(level.index + 1)")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(Palette.inkSoft)
                    Text(level.mission.prompt)
                        .font(.pfBody(16))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)

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
