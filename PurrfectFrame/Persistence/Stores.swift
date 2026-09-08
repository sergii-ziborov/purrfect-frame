import Foundation
import UIKit

final class ProgressStore {
    private let url: URL

    init(fileManager: FileManager = .default) {
        let folder = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PurrfectFrame", isDirectory: true)
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        self.url = folder.appendingPathComponent("progress.json")
    }

    func load() -> ProgressState {
        guard let data = try? Data(contentsOf: url) else { return .fresh }
        return (try? JSONDecoder().decode(ProgressState.self, from: data)) ?? .fresh
    }

    func save(_ state: ProgressState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: url, options: [.atomic])
    }
}

final class PhotoStore {
    private let folder: URL
    private let indexURL: URL

    init(fileManager: FileManager = .default) {
        let root = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PurrfectFrame", isDirectory: true)
        let photos = root.appendingPathComponent("Photos", isDirectory: true)
        try? fileManager.createDirectory(at: photos, withIntermediateDirectories: true)
        self.folder = photos
        self.indexURL = root.appendingPathComponent("photos.json")
    }

    func loadAll() -> [CapturedPhoto] {
        guard let data = try? Data(contentsOf: indexURL) else { return [] }
        let photos = (try? JSONDecoder().decode([CapturedPhoto].self, from: data)) ?? []
        return photos.sorted { $0.createdAt > $1.createdAt }
    }

    func fileURL(for photo: CapturedPhoto) -> URL {
        folder.appendingPathComponent(photo.filename)
    }

    func image(for photo: CapturedPhoto) -> UIImage? {
        UIImage(contentsOfFile: fileURL(for: photo).path)
    }

    @discardableResult
    func save(
        image: UIImage,
        world: WorldID,
        levelIndex: Int,
        missionPrompt: String,
        evaluation: ShotEvaluation
    ) -> CapturedPhoto {
        let id = UUID()
        let filename = "\(id.uuidString).jpg"
        let url = folder.appendingPathComponent(filename)
        if let data = image.jpegData(compressionQuality: 0.86) {
            try? data.write(to: url, options: [.atomic])
        }
        let photo = CapturedPhoto(
            id: id,
            createdAt: Date(),
            world: world,
            levelIndex: levelIndex,
            missionPrompt: missionPrompt,
            success: evaluation.success,
            score: evaluation.score,
            stars: evaluation.stars,
            caption: evaluation.caption,
            filename: filename
        )
        var photos = loadAll()
        photos.insert(photo, at: 0)
        if photos.count > 200 {
            let dropped = photos.suffix(from: 200)
            for extra in dropped {
                try? FileManager.default.removeItem(at: fileURL(for: extra))
            }
            photos = Array(photos.prefix(200))
        }
        if let data = try? JSONEncoder().encode(photos) {
            try? data.write(to: indexURL, options: [.atomic])
        }
        return photo
    }
}
