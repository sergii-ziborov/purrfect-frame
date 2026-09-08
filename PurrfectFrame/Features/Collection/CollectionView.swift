import SwiftUI

struct CollectionView: View {
    @Environment(AppModel.self) private var model

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        ZStack {
            Palette.cream.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button {
                        model.screen = .home
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Palette.ink)
                    }
                    Spacer()
                    Text("Collection")
                        .font(.pfDisplay(22))
                    Spacer()
                    Color.clear.frame(width: 18)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                if model.photos.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 40))
                            .foregroundStyle(Palette.wood)
                        Text("No shots yet")
                            .font(.pfDisplay(24))
                        Text("Funny misses belong here too.")
                            .font(.pfScript(18))
                            .foregroundStyle(Palette.inkSoft)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(model.photos) { photo in
                                Button {
                                    model.screen = .collectionDetail(photo.id)
                                } label: {
                                    polaroidThumb(photo)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
    }

    private func polaroidThumb(_ photo: CapturedPhoto) -> some View {
        VStack(spacing: 8) {
            if let image = model.image(for: photo) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
            } else {
                Rectangle().fill(Palette.creamDark).frame(height: 150)
            }
            Text(photo.caption)
                .font(.pfBody(12))
                .foregroundStyle(Palette.ink)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 34)
        }
        .padding(8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .rotationEffect(.degrees(photo.success ? -1 : 1.6))
    }
}

struct CollectionDetailView: View {
    @Environment(AppModel.self) private var model
    var photoID: UUID

    var body: some View {
        let photo = model.photos.first { $0.id == photoID }
        ZStack {
            Palette.cream.ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    Button {
                        model.screen = .collection
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Palette.ink)
                    }
                    Spacer()
                    Text(photo?.world.title ?? "Shot")
                        .font(.pfDisplay(20))
                    Spacer()
                    Color.clear.frame(width: 18)
                }
                .padding(.horizontal, 20)

                if let photo {
                    VStack(spacing: 12) {
                        if let image = model.image(for: photo) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        Text(photo.caption)
                            .font(.pfScript(22))
                            .foregroundStyle(Palette.wood)
                            .multilineTextAlignment(.center)
                        StarRow(stars: photo.stars)
                        Text(photo.missionPrompt)
                            .font(.pfBody(14))
                            .foregroundStyle(Palette.inkSoft)
                        ShareLink(item: model.photoStore.fileURL(for: photo)) {
                            Label("Share this shot", systemImage: "square.and.arrow.up")
                                .font(.pfBody(16))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Palette.sky, in: Capsule())
                        }
                    }
                    .padding(20)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 20)
                }
                Spacer()
            }
        }
    }
}
