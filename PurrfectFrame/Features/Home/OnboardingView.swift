import SwiftUI

struct OnboardingView: View {
    @Environment(AppModel.self) private var model
    @State private var page = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                pageOne.tag(0)
                pageTwo.tag(1)
                pageThree.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(maxHeight: .infinity)

            Button {
                if page < 2 {
                    withAnimation { page += 1 }
                } else {
                    model.finishIntro()
                }
            } label: {
                Text(page < 2 ? "Next" : "Let's shoot")
                    .font(.pfBody(18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Palette.sky, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

            if page < 2 {
                Button("Skip") { model.finishIntro() }
                    .font(.pfBody(14))
                    .foregroundStyle(Palette.inkSoft)
                    .padding(.bottom, 18)
            } else {
                Color.clear.frame(height: 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Palette.cream.ignoresSafeArea())
        .accessibilityIdentifier("onboarding")
    }

    private var pageOne: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 12)
            Image("BrandMark")
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            Text("Purrfect Frame")
                .font(.pfDisplay(32))
                .foregroundStyle(Palette.ink)
            Text("Catch the perfect group photo.")
                .font(.pfScript(20))
                .foregroundStyle(Palette.wood)
            HStack(spacing: -12) {
                ForEach(CharacterID.cafeCast) { id in
                    CreatureView(id: id, pose: .cameraReady)
                        .scaleEffect(0.42)
                        .frame(width: 72, height: 86)
                }
            }
            .padding(.top, 8)
            Text("Four friends. One job. One tap.")
                .font(.pfBody(15))
                .foregroundStyle(Palette.inkSoft)
            Spacer()
        }
        .padding(.horizontal, 28)
        .multilineTextAlignment(.center)
    }

    private var pageTwo: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 20)
            Text("They will not pose for you.")
                .font(.pfDisplay(26))
                .foregroundStyle(Palette.ink)
            Text("Someone blinks. Someone jumps. Wait, then tap. A big NOW! means it’s a good time.")
                .font(.pfBody(16))
                .foregroundStyle(Palette.inkSoft)
                .padding(.horizontal, 8)
            VStack(alignment: .leading, spacing: 12) {
                tip("eye", "Wait until faces look at you")
                tip("sparkles", "Tap when you see NOW!")
                tip("camera.fill", "Funny misses stay in your album")
            }
            .padding(18)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            Spacer()
        }
        .padding(.horizontal, 24)
        .multilineTextAlignment(.center)
    }

    private var pageThree: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 20)
            Text("Misses belong in the album.")
                .font(.pfDisplay(26))
                .foregroundStyle(Palette.ink)
            Text("A funny blink is still a portrait. Stars live in Ratings. Worlds unlock as you clear shots.")
                .font(.pfBody(16))
                .foregroundStyle(Palette.inkSoft)
            HStack(spacing: 10) {
                mini("globe", "Worlds")
                mini("photo.on.rectangle", "Collection")
                mini("star.fill", "Ratings")
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .multilineTextAlignment(.center)
    }

    private func tip(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Palette.sky)
                .frame(width: 22)
            Text(text)
                .font(.pfBody(14))
                .foregroundStyle(Palette.ink)
            Spacer()
        }
    }

    private func mini(_ icon: String, _ title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
            Text(title)
                .font(.pfBody(12))
        }
        .foregroundStyle(Palette.ink)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
