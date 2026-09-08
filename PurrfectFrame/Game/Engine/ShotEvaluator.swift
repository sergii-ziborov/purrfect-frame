import Foundation

enum ShotEvaluator {
    static func evaluate(
        mission: Mission,
        poses: [CharacterID: Pose],
        cast: [CharacterID]
    ) -> ShotEvaluation {
        let verdicts = cast.map { id -> CharacterVerdict in
            let pose = poses[id] ?? .cameraReady
            return CharacterVerdict(
                id: id,
                looking: pose.isLooking,
                eyesOpen: pose.eyesOpen,
                jumping: pose.isJumping,
                covering: pose.isCovering
            )
        }

        var notes: [String] = []
        var misses = 0

        let lookingCount = verdicts.filter(\.looking).count
        let openCount = verdicts.filter(\.eyesOpen).count
        let jumpCount = verdicts.filter(\.jumping).count
        let coverCount = verdicts.filter(\.covering).count

        switch mission {
        case .allLooking:
            misses += addLookingNotes(verdicts, into: &notes)
            misses += addBlinkNotes(verdicts, into: &notes)
            misses += addCoverNotes(verdicts, into: &notes)
        case .nobodyBlinking:
            misses += addBlinkNotes(verdicts, into: &notes)
            misses += addLookingNotes(verdicts, into: &notes)
        case .noOverlap:
            misses += addCoverNotes(verdicts, into: &notes)
            misses += addLookingNotes(verdicts, into: &notes)
            misses += addBlinkNotes(verdicts, into: &notes)
        case .allStill:
            for verdict in verdicts where verdict.jumping {
                notes.append("\(verdict.id.displayName) launched anyway.")
                misses += 1
            }
            misses += addLookingNotes(verdicts, into: &notes)
            misses += addCoverNotes(verdicts, into: &notes)
        case .twoJumping:
            if jumpCount < 2 {
                notes.append(jumpCount == 1 ? "Only one made it off the ground." : "Everyone kept their paws down.")
                misses += 2 - jumpCount
            }
            misses += addLookingNotes(verdicts, into: &notes)
            misses += addBlinkNotes(verdicts, into: &notes)
            misses += addCoverNotes(verdicts, into: &notes)
        case .catchJumper(let jumper):
            if let verdict = verdicts.first(where: { $0.id == jumper }), !verdict.jumping {
                notes.append("\(jumper.displayName) stayed put.")
                misses += 1
            }
            misses += addLookingNotes(verdicts.filter { $0.id != jumper }, into: &notes)
            misses += addBlinkNotes(verdicts, into: &notes)
            misses += addCoverNotes(verdicts, into: &notes)
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

        let title: String
        let caption: String
        if success {
            title = successTitle(mission: mission)
            caption = successCaption(mission: mission)
        } else {
            title = failTitle(misses: misses)
            caption = notes.first ?? funnyGroupCaption(verdicts: verdicts)
        }

        if !success && notes.isEmpty {
            notes.append(funnyGroupCaption(verdicts: verdicts))
        }

        _ = (lookingCount, openCount, coverCount)

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

    private static func addLookingNotes(_ verdicts: [CharacterVerdict], into notes: inout [String]) -> Int {
        var misses = 0
        for verdict in verdicts where !verdict.looking {
            notes.append("\(verdict.id.displayName) has somewhere better to be.")
            misses += 1
        }
        return misses
    }

    private static func addBlinkNotes(_ verdicts: [CharacterVerdict], into notes: inout [String]) -> Int {
        var misses = 0
        for verdict in verdicts where !verdict.eyesOpen {
            notes.append("\(verdict.id.displayName) chose this exact millisecond to blink.")
            misses += 1
        }
        return misses
    }

    private static func addCoverNotes(_ verdicts: [CharacterVerdict], into notes: inout [String]) -> Int {
        var misses = 0
        for verdict in verdicts where verdict.covering {
            if let target = verdict.id.coverTarget {
                notes.append("\(verdict.id.displayName) photobombed \(target.displayName).")
            } else {
                notes.append("\(verdict.id.displayName) stole the frame.")
            }
            misses += 1
        }
        return misses
    }

    private static func successTitle(mission: Mission) -> String {
        switch mission {
        case .allLooking: "Purrfect!"
        case .twoJumping: "Caught mid-air!"
        case .noOverlap: "Everyone fits!"
        case .nobodyBlinking: "Not a blink."
        case .catchJumper: "That's the hop."
        case .allStill: "Hold still. Got it."
        }
    }

    private static func successCaption(mission: Mission) -> String {
        switch mission {
        case .allLooking: "That's the one. Gallery material."
        case .twoJumping: "Two airborne, two witnesses."
        case .noOverlap: "Personal space: achieved."
        case .nobodyBlinking: "Four pairs of eyes. All of them."
        case .catchJumper(let id): "\(id.displayName) at the top. The others behaved."
        case .allStill: "A quiet miracle."
        }
    }

    private static func failTitle(misses: Int) -> String {
        switch misses {
        case 1: "So close."
        case 2: "Three angels and a gremlin."
        default: "Cute chaos."
        }
    }

    private static func funnyGroupCaption(verdicts: [CharacterVerdict]) -> String {
        if verdicts.filter(\.covering).count >= 2 {
            return "A huddle, not a portrait."
        }
        if verdicts.filter({ !$0.eyesOpen }).count >= 2 {
            return "Mass blink. Unbelievable."
        }
        if verdicts.filter({ !$0.looking }).count >= 2 {
            return "The group had other plans."
        }
        return "A little patience. A lot of purr-sonality."
    }
}
