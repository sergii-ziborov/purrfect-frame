import SwiftUI

struct WorldsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            Palette.cream.ignoresSafeArea()
            VStack(spacing: 0) {
                nav("Worlds")
                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(WorldID.allCases) { world in
                            worldCard(world)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func nav(_ title: String) -> some View {
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
            Text(title)
                .font(.pfDisplay(22))
                .foregroundStyle(Palette.ink)
            Spacer()
            Color.clear.frame(width: 18, height: 18)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private func worldCard(_ world: WorldID) -> some View {
        let levels = LevelCatalog.levels(for: world)
        let cleared = levels.filter { model.progress.stars(for: $0.id) > 0 }.count
        let unlocked = model.progress.isUnlocked(world)

        return Button {
            guard unlocked else { return }
            if let index = LevelCatalog.firstIncomplete(world: world, progress: model.progress) {
                model.play(world: world, index: index)
            } else {
                model.play(world: world, index: 0)
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    Image(world.backgroundAsset)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 168)
                        .clipped()
                    LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(world.title)
                            .font(.pfDisplay(26))
                            .foregroundStyle(.white)
                        Text(world.subtitle)
                            .font(.pfScript(16))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(16)
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(unlocked ? "\(cleared)/\(levels.count)" : "Locked")
                            .font(.pfBody(14))
                            .foregroundStyle(Palette.inkSoft)
                        Spacer()
                        if !unlocked {
                            Label("Clear 4 café shots", systemImage: "lock.fill")
                                .font(.pfBody(12))
                                .foregroundStyle(Palette.inkSoft)
                        }
                    }

                    if unlocked {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: 8)], spacing: 8) {
                            ForEach(levels) { level in
                                levelChip(level)
                            }
                        }
                    }
                }
                .padding(14)
                .background(Color.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
            .opacity(unlocked ? 1 : 0.82)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("world-\(world.rawValue)")
    }

    private func levelChip(_ level: LevelDefinition) -> some View {
        let stars = model.progress.stars(for: level.id)
        let open = model.progress.isLevelUnlocked(level)
        return Button {
            guard open else { return }
            model.play(world: level.world, index: level.index)
        } label: {
            VStack(spacing: 4) {
                Text("\(level.index + 1)")
                    .font(.pfBody(14))
                    .foregroundStyle(open ? Palette.ink : Palette.ink.opacity(0.3))
                HStack(spacing: 1) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.system(size: 7))
                            .foregroundStyle(i < stars ? Palette.gold : Palette.ink.opacity(0.15))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                open ? Palette.creamDark : Palette.creamDark.opacity(0.4),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(!open)
    }
}
