import Foundation
import Testing
@testable import PurrfectFrame

struct TimelineBuilderTests {
    @Test("Every seed has an achievable success window")
    func guaranteedWindow() {
        let missions: [Mission] = [
            .allLooking, .twoJumping, .noOverlap, .nobodyBlinking, .allStill,
            .catchJumper(.butter), .catchYawn(.nori), .catchWave(.mochi), .nobodyYawning,
        ]
        let difficulties: [Difficulty] = [.easy, .medium, .hard]
        let cast = CharacterID.cafeCast
        var failures: [String] = []

        for mission in missions {
            for difficulty in difficulties {
                for seed: UInt64 in 1...24 {
                    let timeline = TimelineBuilder.build(
                        mission: mission,
                        cast: cast,
                        difficulty: difficulty,
                        seed: seed &* 7919
                    )
                    let hits = successTimes(timeline)
                    let span = runLength(hits, step: 1.0 / 30.0)
                    if hits.isEmpty {
                        failures.append("no window \(mission) \(difficulty.windowDuration) seed \(seed)")
                    } else if span + 0.001 < difficulty.windowDuration * 0.55 {
                        failures.append("short window \(mission) seed \(seed) span \(span)")
                    }
                }
            }
        }

        #expect(failures.isEmpty, "\(failures.prefix(12).joined(separator: "; "))")
    }

    @Test("Declared success window evaluates as success")
    func declaredWindowMatchesEvaluator() {
        let timeline = TimelineBuilder.build(
            mission: .allLooking,
            cast: CharacterID.cafeCast,
            difficulty: .medium,
            seed: 42
        )
        let mid = (timeline.successWindow.lowerBound + timeline.successWindow.upperBound) / 2
        let poses = timeline.snapshot(at: mid)
        let evaluation = ShotEvaluator.evaluate(
            mission: timeline.mission,
            poses: poses,
            cast: timeline.cast
        )
        #expect(evaluation.success)
        #expect(evaluation.stars == 3)
    }

    @Test("Poses stay in 0...1")
    func poseBounds() {
        let timeline = TimelineBuilder.build(
            mission: .noOverlap,
            cast: CharacterID.penguinCast,
            difficulty: .hard,
            seed: 99
        )
        var t = 0.0
        while t < timeline.loopDuration {
            for pose in timeline.snapshot(at: t).values {
                #expect(pose.facing >= -0.01 && pose.facing <= 1.01)
                #expect(pose.blink >= -0.01 && pose.blink <= 1.01)
                #expect(pose.jump >= -0.01 && pose.jump <= 1.01)
                #expect(pose.cover >= -0.01 && pose.cover <= 1.01)
            }
            t += 1.0 / 20.0
        }
    }

    private func successTimes(_ timeline: RoundTimeline) -> [TimeInterval] {
        let step = 1.0 / 30.0
        var hits: [TimeInterval] = []
        var t = 0.0
        while t < timeline.loopDuration {
            let poses = timeline.snapshot(at: t)
            let evaluation = ShotEvaluator.evaluate(
                mission: timeline.mission,
                poses: poses,
                cast: timeline.cast
            )
            if evaluation.success {
                hits.append(t)
            }
            t += step
        }
        return hits
    }

    private func runLength(_ hits: [TimeInterval], step: TimeInterval) -> TimeInterval {
        guard let first = hits.first else { return 0 }
        var best = step
        var current = step
        var previous = first
        for time in hits.dropFirst() {
            if time - previous < step * 1.6 {
                current += time - previous
            } else {
                best = max(best, current)
                current = step
            }
            previous = time
        }
        return max(best, current)
    }
}

struct ShotEvaluatorTests {
    @Test("All looking camera-ready is a hit")
    func allLookingHit() {
        var poses: [CharacterID: Pose] = [:]
        for id in CharacterID.cafeCast {
            poses[id] = .cameraReady
        }
        let result = ShotEvaluator.evaluate(mission: .allLooking, poses: poses, cast: CharacterID.cafeCast)
        #expect(result.success)
        #expect(result.score == 100)
    }

    @Test("A blink is a miss with a named note")
    func blinkMiss() {
        var poses: [CharacterID: Pose] = [:]
        for id in CharacterID.cafeCast {
            poses[id] = .cameraReady
        }
        poses[.nori]?.blink = 1
        let result = ShotEvaluator.evaluate(mission: .allLooking, poses: poses, cast: CharacterID.cafeCast)
        #expect(!result.success)
        #expect(result.caption.contains("Nori"))
        #expect(result.stars == 1)
    }

    @Test("Covering is a photobomb miss")
    func coverMiss() {
        var poses: [CharacterID: Pose] = [:]
        for id in CharacterID.cafeCast {
            poses[id] = .cameraReady
        }
        poses[.ink]?.cover = 1
        let result = ShotEvaluator.evaluate(mission: .noOverlap, poses: poses, cast: CharacterID.cafeCast)
        #expect(!result.success)
        #expect(result.notes.contains { $0.contains("Ink") })
    }

    @Test("Two jumping needs two airborne")
    func twoJumping() {
        var poses: [CharacterID: Pose] = [:]
        for id in CharacterID.cafeCast {
            poses[id] = .cameraReady
        }
        poses[.butter]?.jump = 1
        let miss = ShotEvaluator.evaluate(mission: .twoJumping, poses: poses, cast: CharacterID.cafeCast)
        #expect(!miss.success)

        poses[.mochi]?.jump = 1
        let hit = ShotEvaluator.evaluate(mission: .twoJumping, poses: poses, cast: CharacterID.cafeCast)
        #expect(hit.success)
    }

    @Test("Catch jumper requires that character in the air")
    func catchJumper() {
        var poses: [CharacterID: Pose] = [:]
        for id in CharacterID.cafeCast {
            poses[id] = .cameraReady
        }
        let miss = ShotEvaluator.evaluate(mission: .catchJumper(.butter), poses: poses, cast: CharacterID.cafeCast)
        #expect(!miss.success)
        poses[.butter]?.jump = 1
        let hit = ShotEvaluator.evaluate(mission: .catchJumper(.butter), poses: poses, cast: CharacterID.cafeCast)
        #expect(hit.success)
    }
}

struct CatalogTests {
    @Test("Penguins unlock after four café successes")
    func penguinUnlock() {
        var progress = ProgressState.fresh
        #expect(!progress.penguinsUnlocked)
        for level in LevelCatalog.cafe.prefix(4) {
            progress.recordSuccess(level: level, stars: 3)
        }
        #expect(progress.penguinsUnlocked)
        #expect(progress.isLevelUnlocked(LevelCatalog.penguins[0]))
    }

    @Test("Dogs unlock after three penguin successes")
    func dogUnlock() {
        var progress = ProgressState.fresh
        for level in LevelCatalog.cafe.prefix(4) {
            progress.recordSuccess(level: level, stars: 1)
        }
        #expect(!progress.dogsUnlocked)
        for level in LevelCatalog.penguins.prefix(3) {
            progress.recordSuccess(level: level, stars: 1)
        }
        #expect(progress.dogsUnlocked)
        #expect(progress.isUnlocked(.dogs))
    }

    @Test("Levels stay sequential")
    func sequentialUnlock() {
        var progress = ProgressState.fresh
        #expect(progress.isLevelUnlocked(LevelCatalog.cafe[0]))
        #expect(!progress.isLevelUnlocked(LevelCatalog.cafe[1]))
        progress.recordSuccess(level: LevelCatalog.cafe[0], stars: 1)
        #expect(progress.isLevelUnlocked(LevelCatalog.cafe[1]))
    }
}
