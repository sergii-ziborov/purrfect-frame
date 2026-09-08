import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        GeometryReader { geo in
            let short = geo.size.height < 720
            Palette.cream
                .ignoresSafeArea()
                .overlay {
                    Image("CafeBackground")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.18)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
                .overlay {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: short ? 12 : 22) {
                            header(short: short)
                            featureRow(short: short)
                            quote(short: short)
                            actions
                            Text("Small moments. Happier days.")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Palette.inkSoft)
                                .padding(.top, short ? 2 : 8)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, short ? 10 : 28)
                        .frame(maxWidth: sizeClass == .regular ? 560 : .infinity)
                        .frame(maxWidth: .infinity)
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func header(short: Bool) -> some View {
        VStack(spacing: short ? 6 : 10) {
            Image("BrandMark")
                .resizable()
                .scaledToFit()
                .frame(width: short ? 72 : 96, height: short ? 72 : 96)
                .clipShape(RoundedRectangle(cornerRadius: short ? 18 : 24, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 10, y: 6)

            Text("Purrfect Frame")
                .font(.pfDisplay(short ? 30 : 36))
                .foregroundStyle(Palette.ink)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text("Catch the perfect group photo")
                .font(.pfScript(short ? 17 : 20))
                .foregroundStyle(Palette.wood)
        }
        .padding(.top, short ? 4 : 12)
    }

    private func featureRow(short: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            FeaturePill(icon: "hand.tap.fill", title: "One tap", subtitle: "simple & fun", tint: Palette.coral, compact: short)
            FeaturePill(icon: "calendar", title: "Daily challenge", subtitle: "new moment every day", tint: Palette.moss, compact: short)
            FeaturePill(icon: "cat.fill", title: "Cute chaos", subtitle: "they do their own thing", tint: Palette.sky, compact: short)
        }
        .padding(.top, short ? 2 : 8)
    }

    private func quote(short: Bool) -> some View {
        VStack(spacing: 2) {
            Text("A little patience.")
            Text("A lot of purr-sonality.")
        }
        .font(.pfScript(short ? 18 : 22))
        .foregroundStyle(Palette.inkSoft)
        .multilineTextAlignment(.center)
        .padding(.vertical, short ? 2 : 6)
    }

    private var actions: some View {
        VStack(spacing: 12) {
            PFButton(title: "Play", kind: .play, icon: "camera.fill") {
                model.playTapped()
            }
            .accessibilityIdentifier("play-button")

            HStack(spacing: 10) {
                miniButton("Worlds", icon: "globe") { model.screen = .worlds }
                miniButton("Collection", icon: "photo.on.rectangle") { model.screen = .collection }
                miniButton("Settings", icon: "gearshape.fill") { model.screen = .settings }
            }

            Button {
                model.playDaily()
            } label: {
                Label("Today's challenge", systemImage: "sparkles")
                    .font(.pfBody(15))
                    .foregroundStyle(Palette.wood)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("daily-button")
        }
    }

    private func miniButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.pfBody(12))
            }
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
