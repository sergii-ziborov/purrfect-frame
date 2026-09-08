import SwiftUI

@main
struct PurrfectFrameApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
        }
    }
}

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            switch model.screen {
            case .home:
                HomeView()
            case .play:
                CameraPlayView()
            case .result:
                ResultView()
            case .worlds:
                WorldsView()
            case .collection:
                CollectionView()
            case .collectionDetail(let id):
                CollectionDetailView(photoID: id)
            case .settings:
                SettingsView()
            }
        }
        .animation(.easeInOut(duration: 0.22), value: screenKey)
        .tint(Palette.sky)
    }

    private var screenKey: String {
        switch model.screen {
        case .home: "home"
        case .play: "play"
        case .result: "result"
        case .worlds: "worlds"
        case .collection: "collection"
        case .collectionDetail: "photo"
        case .settings: "settings"
        }
    }
}
