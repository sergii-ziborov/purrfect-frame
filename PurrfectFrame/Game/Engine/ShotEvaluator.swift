import Foundation

enum ShotEvaluator {
    static func evaluate(
        mission: Mission,
        poses: [CharacterID: Pose],
        cast: [CharacterID]
    ) -> ShotEvaluation {
        var notes: [String] = []
        var misses = 0

        switch mission {
        case .allLooking:
            misses += lookingMisses(poses, cast: cast, into: &notes)
            misses += blinkMisses(poses, cast: cast, into: &notes)
            misses += coverMisses(poses, cast: cast, into: &notes)
        case .nobodyBlinking:
            misses += blinkMisses(poses, cast: cast, into: &notes)
            misses += lookingMisses(poses, cast: cast, into: &notes)
        case .noOverlap:
            misses += coverMisses(poses, cast: cast, into: &notes)
            misses += lookingMisses(poses, cast: cast, into: &notes)
            misses += blinkMisses(poses, cast: cast, into: &notes)
        case .allStill:
            for id in cast where (poses[id]?.isJumping ?? false) {
                notes.append("\(id.displayName) jumped.")
                misses += 1
            }
            misses += lookingMisses(poses, cast: cast, into: &notes)
            misses += coverMisses(poses, cast: cast, into: &notes)
        case .twoJumping:
            let jumpCount = cast.filter { poses[$0]?.isJumping ?? false }.count
            if jumpCount < 2 {
                notes.append(jumpCount == 1 ? "Need 2 jumping. Only one jumped." : "Need 2 jumping. Nobody jumped.")
                misses += 2 - jumpCount
            }
            misses += lookingMisses(poses, cast: cast, into: &notes)
            misses += blinkMisses(poses, cast: cast, into: &notes)
            misses += coverMisses(poses, cast: cast, into: &notes)
        case .catchJumper(let jumper):
            if poses[jumper]?.isJumping != true {
                notes.append("Tap when \(jumper.displayName) jumps.")
                misses += 1
            }
            misses += lookingMisses(poses, cast: cast.filter { $0 != jumper }, into: &notes)
            misses += blinkMisses(poses, cast: cast, into: &notes)
            misses += coverMisses(poses, cast: cast, into: &notes)
        case .catchYawn(let who):
            if poses[who]?.isYawning != true {
                notes.append("Tap when \(who.displayName) yawns.")
                misses += 1
            }
            misses += lookingMisses(poses, cast: cast.filter { $0 != who }, into: &notes)
            misses += coverMisses(poses, cast: cast, into: &notes)
        case .catchWave(let who):
            if poses[who]?.isWaving != true {
                notes.append("Tap when \(who.displayName) waves.")
                misses += 1
            }
            misses += lookingMisses(poses, cast: cast.filter { $0 != who }, into: &notes)
            misses += blinkMisses(poses, cast: cast, into: &notes)
        case .nobodyYawning:
            for id in cast where (poses[id]?.isYawning ?? false) {
                notes.append("\(id.displayName) yawned.")
                misses += 1
            }
            misses += lookingMisses(poses, cast: cast, into: &notes)
            misses += blinkMisses(poses, cast: cast, into: &notes)
        }

        let success = misses == 0
        let score: Int
        let stars: Int
        if success {
            score = 100
            stars = 3
        } else if misses == 1 {
            score = 68
            stars = 1
        } else if misses == 2 {
            score = 42
            stars = 0
        } else {
            score = max(8, 28 - misses * 4)
            stars = 0
        }

        let verdicts = cast.map { id in
            makeVerdict(id: id, pose: poses[id] ?? .cameraReady, mission: mission, jumpCount: cast.filter { poses[$0]?.isJumping ?? false }.count)
        }

        let title: String
        let caption: String
        if success {
            title = "You got it!"
            caption = successCaption(mission: mission)
        } else {
            title = misses == 1 ? "So close!" : "Almost!"
            caption = notes.first ?? "Try tapping when the hint says NOW!"
        }

        if !success && notes.isEmpty {
            notes.append(caption)
        }

        return ShotEvaluation(
            success: success,
            score: score,
            stars: stars,
            title: title,
            caption: caption,
            notes: notes,
            verdicts: verdicts
        )
    }

    private static func makeVerdict(
        id: CharacterID,
        pose: Pose,
        mission: Mission,
        jumpCount: Int
    ) -> CharacterVerdict {
        let name = id.displayName
        let looking = pose.isLooking
        let eyesOpen = pose.eyesOpen
        let jumping = pose.isJumping
        let covering = pose.isCovering
        let yawning = pose.isYawning
        let waving = pose.isWaving

        var ok = true
        var line = "\(name) looks great"

        if covering {
            ok = false
            line = "\(name) covered a friend"
        } else if !looking {
            ok = false
            line = "\(name) looked away"
        } else if !eyesOpen && !yawning {
            ok = false
            line = "\(name) blinked"
        }

        switch mission {
        case .allStill where jumping:
            ok = false
            line = "\(name) jumped"
        case .catchJumper(let jumper) where id == jumper:
            if jumping {
                ok = !covering
                line = ok ? "\(name) jumped!" : line
            } else {
                ok = false
                line = "Need \(name) jumping"
            }
        case .catchYawn(let who) where id == who:
            if yawning {
                ok = !covering
                line = ok ? "\(name) yawned!" : line
            } else {
                ok = false
                line = "Need \(name) yawning"
            }
        case .catchWave(let who) where id == who:
            if waving {
                ok = looking && !covering
                line = ok ? "\(name) waved!" : line
            } else {
                ok = false
                line = "Need \(name) waving"
            }
        case .nobodyYawning where yawning:
            ok = false
            line = "\(name) yawned"
        case .twoJumping:
            if jumpCount < 2 && !jumping {
                ok = false
                line = "Need more jumping"
            } else if jumping {
                line = "\(name) jumped"
            }
        default:
            break
        }

        return CharacterVerdict(
            id: id,
            looking: looking,
            eyesOpen: eyesOpen,
            jumping: jumping,
            covering: covering,
            yawning: yawning,
            waving: waving,
            ok: ok,
            line: line
        )
    }

    private static func lookingMisses(
        _ poses: [CharacterID: Pose],
        cast: [CharacterID],
        into notes: inout [String]
    ) -> Int {
        var misses = 0
        for id in cast where !(poses[id]?.isLooking ?? true) {
            notes.append("\(id.displayName) looked away.")
            misses += 1
        }
        return misses
    }

    private static func blinkMisses(
        _ poses: [CharacterID: Pose],
        cast: [CharacterID],
        into notes: inout [String]
    ) -> Int {
        var misses = 0
        for id in cast {
            let pose = poses[id] ?? .cameraReady
            if !pose.eyesOpen && !pose.isYawning {
                notes.append("\(id.displayName) blinked.")
                misses += 1
            }
        }
        return misses
    }

    private static func coverMisses(
        _ poses: [CharacterID: Pose],
        cast: [CharacterID],
        into notes: inout [String]
    ) -> Int {
        var misses = 0
        for id in cast where (poses[id]?.isCovering ?? false) {
            notes.append("\(id.displayName) covered a friend.")
            misses += 1
        }
        return misses
    }

    private static func successCaption(mission: Mission) -> String {
        switch mission {
        case .allLooking: "All 4 friends are looking. Nice!"
        case .twoJumping: "Two friends in the air!"
        case .noOverlap: "Every face has space."
        case .nobodyBlinking: "Nobody blinked. Super!"
        case .catchJumper(let id): "You caught \(id.displayName)’s jump!"
        case .allStill: "Everyone sat still."
        case .catchYawn(let id): "You caught \(id.displayName)’s yawn!"
        case .catchWave(let id): "\(id.displayName) waved. You tapped it!"
        case .nobodyYawning: "Everyone is awake."
        }
    }
}
