import SwiftUI
import UIKit

enum Screen: Equatable {
    case home
    case play
    case result
    case worlds
    case collection
    case collectionDetail(UUID)
    case settings
}

struct ShotOutcome: Equatable {
    var evaluation: ShotEvaluation
    var photo: CapturedPhoto
}

@MainActor
@Observable
final class AppModel {
    var screen: Screen = .home
    var progress: ProgressState
    var photos: [CapturedPhoto]
    var session: RoundSession?
    var lastOutcome: ShotOutcome?

    let photoStore: PhotoStore
    private let progressStore: ProgressStore

    init() {
        let progressStore = ProgressStore()
        let photoStore = PhotoStore()
        self.progressStore = progressStore
        self.photoStore = photoStore
        self.progress = progressStore.load()
        self.photos = photoStore.loadAll()
    }

    func playTapped() {
        let next = LevelCatalog.nextPlayable(progress: progress)
        startPlay(world: next.world, index: next.index, daily: false)
    }

    func playDaily() {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 1
        var worlds: [WorldID] = [.cafe]
        if progress.penguinsUnlocked { worlds.append(.penguins) }
        if progress.dogsUnlocked { worlds.append(.dogs) }
        if progress.rabbitsUnlocked { worlds.append(.rabbits) }
        if progress.foxesUnlocked { worlds.append(.foxes) }
        if progress.owlsUnlocked { worlds.append(.owls) }
        let world = worlds[day % worlds.count]
        let levels = LevelCatalog.levels(for: world)
        let index = day % levels.count
        startPlay(world: world, index: index, daily: true, seed: UInt64(day) &* 1_000_003)
    }

    func play(world: WorldID, index: Int) {
        startPlay(world: world, index: index, daily: false)
    }

    func retry() {
        guard let session else { return }
        startPlay(world: session.context.world, index: session.context.levelIndex, daily: session.context.isDaily)
    }

    func nextLevel() {
        guard let session else {
            screen = .home
            return
        }
        let world = session.context.world
        let nextIndex = session.context.levelIndex + 1
        if nextIndex < LevelCatalog.levels(for: world).count {
            startPlay(world: world, index: nextIndex, daily: false)
        } else if world == .cafe, progress.penguinsUnlocked {
            startPlay(world: .penguins, index: 0, daily: false)
        } else if world == .penguins, progress.dogsUnlocked {
            startPlay(world: .dogs, index: 0, daily: false)
        } else if world == .dogs, progress.rabbitsUnlocked {
            startPlay(world: .rabbits, index: 0, daily: false)
        } else if world == .rabbits, progress.foxesUnlocked {
            startPlay(world: .foxes, index: 0, daily: false)
        } else if world == .foxes, progress.owlsUnlocked {
            startPlay(world: .owls, index: 0, daily: false)
        } else {
            screen = .worlds
            self.session = nil
        }
    }

    func capture(image: UIImage, evaluation: ShotEvaluation) {
        guard let session else { return }
        let photo = photoStore.save(
            image: image,
            world: session.context.world,
            levelIndex: session.context.levelIndex,
            missionPrompt: session.context.level.mission.prompt,
            evaluation: evaluation
        )
        photos.insert(photo, at: 0)
        if evaluation.success {
            progress.recordSuccess(level: session.context.level, stars: evaluation.stars)
            progressStore.save(progress)
            Feedback.success(haptics: progress.hapticsEnabled)
        } else {
            Feedback.miss(haptics: progress.hapticsEnabled)
        }
        lastOutcome = ShotOutcome(evaluation: evaluation, photo: photo)
        screen = .result
    }

    func saveProgress() {
        progressStore.save(progress)
    }

    func resetProgress() {
        progress = .fresh
        progressStore.save(progress)
    }

    func image(for photo: CapturedPhoto) -> UIImage? {
        photoStore.image(for: photo)
    }

    func goHome() {
        session = nil
        lastOutcome = nil
        screen = .home
    }

    private func startPlay(world: WorldID, index: Int, daily: Bool, seed: UInt64? = nil) {
        let context = PlayContext(
            world: world,
            levelIndex: index,
            seed: seed ?? UInt64.random(in: 1...UInt64.max),
            isDaily: daily
        )
        session = RoundSession(context: context)
        lastOutcome = nil
        screen = .play
    }
}

@MainActor
@Observable
final class RoundSession {
    let context: PlayContext
    let timeline: RoundTimeline
    let startDate: Date
    var freeze: Freeze?

    struct Freeze: Equatable {
        var time: TimeInterval
        var poses: [CharacterID: Pose]
        var evaluation: ShotEvaluation
    }

    init(context: PlayContext) {
        self.context = context
        let level = context.level
        self.timeline = TimelineBuilder.build(
            mission: level.mission,
            cast: level.cast,
            difficulty: level.difficulty,
            seed: context.seed
        )
        self.startDate = Date()
    }

    func poses(at now: Date) -> [CharacterID: Pose] {
        if let freeze { return freeze.poses }
        let time = now.timeIntervalSince(startDate)
        return timeline.snapshot(at: time)
    }

    func elapsed(at now: Date) -> TimeInterval {
        now.timeIntervalSince(startDate)
    }

    func freeze(at now: Date) -> Freeze {
        let time = now.timeIntervalSince(startDate)
        let poses = timeline.snapshot(at: time)
        let evaluation = ShotEvaluator.evaluate(
            mission: timeline.mission,
            poses: poses,
            cast: timeline.cast
        )
        let freeze = Freeze(time: time, poses: poses, evaluation: evaluation)
        self.freeze = freeze
        return freeze
    }
}
