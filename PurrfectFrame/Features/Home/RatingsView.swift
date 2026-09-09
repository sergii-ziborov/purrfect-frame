import SwiftUI

struct RatingsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        PFScreen(title: "Ratings", onBack: { model.screen = .home }) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    summary
                    ForEach(WorldID.allCases) { world in
                        worldRow(world)
                    }
                }
                .padding(20)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(model.progress.photographerRank)
                .font(.pfDisplay(28))
                .foregroundStyle(Palette.ink)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Palette.gold)
                Text("\(model.progress.totalStars)")
                    .font(.pfDisplay(34))
                Text("/ \(model.progress.possibleStars)")
                    .font(.pfBody(16))
                    .foregroundStyle(Palette.inkSoft)
            }
            Text("\(model.progress.clearedLevels) levels cleared  ·  \(model.photos.count) shots in the collection")
                .font(.pfBody(13))
                .foregroundStyle(Palette.inkSoft)
            GeometryReader { geo in
                let ratio = model.progress.possibleStars == 0
                    ? 0
                    : CGFloat(model.progress.totalStars) / CGFloat(model.progress.possibleStars)
                ZStack(alignment: .leading) {
                    Capsule().fill(Palette.creamDark)
                    Capsule()
                        .fill(Palette.gold)
                        .frame(width: max(8, geo.size.width * ratio))
                }
            }
            .frame(height: 10)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func worldRow(_ world: WorldID) -> some View {
        let earned = model.progress.earnedStars(in: world)
        let possible = model.progress.possibleStars(in: world)
        let unlocked = model.progress.isUnlocked(world)
        let ratio = possible == 0 ? 0 : CGFloat(earned) / CGFloat(possible)

        return Button {
            guard unlocked else { return }
            model.screen = .worlds
        } label: {
            HStack(spacing: 12) {
                Image(world.backgroundAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64, alignment: .bottom)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(world.title)
                            .font(.pfBody(16))
                            .foregroundStyle(Palette.ink)
                        Spacer()
                        if unlocked {
                            Text("\(earned)/\(possible)")
                                .font(.pfBody(13))
                                .foregroundStyle(Palette.inkSoft)
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Palette.inkSoft)
                        }
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Palette.creamDark)
                            Capsule()
                                .fill(unlocked ? Palette.gold : Palette.ink.opacity(0.12))
                                .frame(width: max(unlocked ? 6 : 0, geo.size.width * ratio))
                        }
                    }
                    .frame(height: 7)
                }
            }
            .padding(12)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .opacity(unlocked ? 1 : 0.7)
    }
}
