import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        GeometryReader { geo in
            let short = geo.size.height < 720
            let next = LevelCatalog.nextPlayable(progress: model.progress)
            let level = LevelCatalog.level(world: next.world, index: next.index)

            VStack(spacing: short ? 12 : 18) {
                header
                playCard(level: level, short: short)
                destRow
                dailyRow
                ratingsStrip
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, short ? 8 : 16)
            .padding(.bottom, 12)
            .frame(maxWidth: sizeClass == .regular ? 560 : .infinity)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                Palette.cream
                    .ignoresSafeArea()
                    .overlay {
                        Image("CafeBackground")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.14)
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                    }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image("BrandMark")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text("Purrfect Frame")
                    .font(.pfDisplay(22))
                    .foregroundStyle(Palette.ink)
                Text(model.progress.photographerRank)
                    .font(.pfBody(12))
                    .foregroundStyle(Palette.wood)
            }
            Spacer()
            Button {
                model.screen = .settings
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.88), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
            .accessibilityIdentifier("Settings")
        }
    }

    private func playCard(level: LevelDefinition, short: Bool) -> some View {
        Button {
            model.playTapped()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    SceneCrop(name: level.world.background(for: level.index), height: short ? 148 : 176)
                    LinearGradient(colors: [.clear, .black.opacity(0.58)], startPoint: .center, endPoint: .bottom)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(level.world.title.uppercased())
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .tracking(1.1)
                            .foregroundStyle(.white.opacity(0.8))
                        Text("Level \(level.index + 1)")
                            .font(.pfDisplay(26))
                            .foregroundStyle(.white)
                        Text(level.mission.prompt)
                            .font(.pfBody(14))
                            .foregroundStyle(.white.opacity(0.92))
                    }
                    .padding(16)
                }
                HStack {
                    Label("Play", systemImage: "camera.fill")
                        .font(.pfBody(17))
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(Palette.sky)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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
            .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                Text("Today's challenge")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .font(.pfBody(15))
            .foregroundStyle(Palette.wood)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("daily-button")
    }

    private var ratingsStrip: some View {
        Button {
            model.screen = .ratings
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Stars")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(Palette.inkSoft)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Palette.gold)
                        Text("\(model.progress.totalStars)")
                            .font(.pfDisplay(22))
                            .foregroundStyle(Palette.ink)
                        Text("/ \(model.progress.possibleStars)")
                            .font(.pfBody(13))
                            .foregroundStyle(Palette.inkSoft)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Shots")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(Palette.inkSoft)
                    Text("\(model.photos.count)")
                        .font(.pfDisplay(22))
                        .foregroundStyle(Palette.ink)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Ratings")
    }
}
