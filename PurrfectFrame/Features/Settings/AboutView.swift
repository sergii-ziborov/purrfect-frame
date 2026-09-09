import SwiftUI

struct AboutView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        PFScreen(title: "About", onBack: { model.screen = .settings }) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Image("BrandMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 84, height: 84)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding(.top, 8)

                    Text("Purrfect Frame")
                        .font(.pfDisplay(28))
                        .foregroundStyle(Palette.ink)
                    Text("Catch the perfect group photo")
                        .font(.pfScript(18))
                        .foregroundStyle(Palette.wood)

                    HStack(alignment: .top, spacing: 8) {
                        FeaturePill(icon: "hand.tap.fill", title: "One tap", subtitle: "simple & fun", tint: Palette.coral)
                        FeaturePill(icon: "calendar", title: "Daily", subtitle: "a new moment", tint: Palette.moss)
                        FeaturePill(icon: "cat.fill", title: "Cute chaos", subtitle: "they do their thing", tint: Palette.sky)
                    }
                    .padding(.top, 4)

                    VStack(spacing: 6) {
                        Text("A little patience.")
                        Text("A lot of purr-sonality.")
                    }
                    .font(.pfScript(20))
                    .foregroundStyle(Palette.inkSoft)
                    .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("How a round works")
                            .font(.pfBody(16))
                            .foregroundStyle(Palette.ink)
                        Text("Each shot has one job — all four looking, two in the air, nobody blinking. The game always places a real window where that job is possible. You can miss. You cannot be handed an impossible frame.")
                            .font(.system(size: 15))
                            .foregroundStyle(Palette.inkSoft)
                        Text("Funny misses stay in Collection. Stars live in Ratings. Worlds unlock as you clear shots.")
                            .font(.system(size: 15))
                            .foregroundStyle(Palette.inkSoft)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Text("Small moments. Happier days.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Palette.inkSoft)
                    Text("Version 1.0.0")
                        .font(.pfBody(12))
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}
