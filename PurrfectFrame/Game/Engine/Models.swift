import Foundation
import SwiftUI

enum Species: String, Codable, CaseIterable, Sendable {
    case cat
    case penguin
}

enum WorldID: String, Codable, CaseIterable, Identifiable, Sendable {
    case cafe
    case penguins

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cafe: "Cat Café"
        case .penguins: "Penguin Parade"
        }
    }

    var subtitle: String {
        switch self {
        case .cafe: "Warm light, worse timing."
        case .penguins: "One silhouette. Many opinions."
        }
    }

    var species: Species {
        switch self {
        case .cafe: .cat
        case .penguins: .penguin
        }
    }

    var backgroundAsset: String {
        switch self {
        case .cafe: "CafeBackground"
        case .penguins: "PenguinBackground"
        }
    }
}

enum CharacterID: String, Codable, CaseIterable, Identifiable, Sendable {
    case mochi, nori, butter, ink
    case pip, waddle, scoop, pebble

    var id: String { rawValue }

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var species: Species {
        switch self {
        case .mochi, .nori, .butter, .ink: .cat
        case .pip, .waddle, .scoop, .pebble: .penguin
        }
    }

    var personality: Personality {
        switch self {
        case .nori, .pip: .blinker
        case .mochi, .pebble: .turner
        case .butter, .scoop: .jumper
        case .ink, .waddle: .coverer
        }
    }

    var coverTarget: CharacterID? {
        switch self {
        case .ink: .nori
        case .waddle: .pip
        case .mochi: .butter
        case .scoop: .pebble
        default: nil
        }
    }

    static let cafeCast: [CharacterID] = [.mochi, .nori, .butter, .ink]
    static let penguinCast: [CharacterID] = [.pip, .waddle, .scoop, .pebble]

    static func cast(for world: WorldID) -> [CharacterID] {
        switch world {
        case .cafe: cafeCast
        case .penguins: penguinCast
        }
    }
}

enum Personality: String, Sendable {
    case blinker, turner, jumper, coverer
}

enum Mouth: String, Codable, Sendable {
    case smile, open, derp, tongue, flat
}

struct Pose: Equatable, Sendable {
    /// 0 = facing the camera, 1 = fully turned away.
    var facing: Double
    /// -1 turns left, 1 turns right.
    var turnSign: Double
    /// 0 = eyes open, 1 = eyes shut.
    var blink: Double
    /// 0 = grounded, 1 = jump peak.
    var jump: Double
    /// 0 = in slot, 1 = covering a neighbor.
    var cover: Double
    var mouth: Mouth
    /// Idle breathing 0...1.
    var breath: Double

    static let cameraReady = Pose(
        facing: 0, turnSign: 1, blink: 0, jump: 0, cover: 0, mouth: .smile, breath: 0.4
    )

    var isLooking: Bool { facing < 0.28 }
    var eyesOpen: Bool { blink < 0.45 }
    var isJumping: Bool { jump > 0.45 }
    var isCovering: Bool { cover > 0.4 }
}

enum Mission: Equatable, Codable, Hashable, Sendable {
    case allLooking
    case twoJumping
    case noOverlap
    case nobodyBlinking
    case catchJumper(CharacterID)
    case allStill

    var prompt: String {
        switch self {
        case .allLooking: "Get all 4 looking"
        case .twoJumping: "Catch two in mid-air"
        case .noOverlap: "No overlapping faces"
        case .nobodyBlinking: "Nobody blinking"
        case .catchJumper(let id): "Catch \(id.displayName) in a jump"
        case .allStill: "Everyone sitting still"
        }
    }

    var hint: String {
        switch self {
        case .allLooking: "Eyes open, faces to the camera."
        case .twoJumping: "Two airborne. The other two looking."
        case .noOverlap: "Give every face its own space."
        case .nobodyBlinking: "Hold for the blink to pass."
        case .catchJumper(let id): "\(id.displayName) at the top of the hop."
        case .allStill: "Paws on the ground. Faces forward."
        }
    }
}

struct Difficulty: Equatable, Sendable {
    var windowDuration: TimeInterval
    var chaosCount: Int

    static let easy = Difficulty(windowDuration: 1.35, chaosCount: 3)
    static let medium = Difficulty(windowDuration: 0.90, chaosCount: 5)
    static let hard = Difficulty(windowDuration: 0.55, chaosCount: 7)
}

struct LevelDefinition: Equatable, Identifiable, Sendable {
    var world: WorldID
    var index: Int
    var mission: Mission
    var difficulty: Difficulty

    var id: String { "\(world.rawValue).\(index)" }
    var cast: [CharacterID] { CharacterID.cast(for: world) }
}

struct PlayContext: Equatable, Sendable {
    var world: WorldID
    var levelIndex: Int
    var seed: UInt64
    var isDaily: Bool

    var level: LevelDefinition {
        LevelCatalog.level(world: world, index: levelIndex)
    }
}

enum LevelCatalog {
    static let cafe: [LevelDefinition] = make(
        world: .cafe,
        missions: [
            (.allLooking, .easy),
            (.allLooking, .easy),
            (.nobodyBlinking, .easy),
            (.allLooking, .medium),
            (.noOverlap, .medium),
            (.catchJumper(.butter), .medium),
            (.twoJumping, .medium),
            (.allStill, .medium),
            (.allLooking, .hard),
            (.noOverlap, .hard),
            (.twoJumping, .hard),
            (.nobodyBlinking, .hard),
        ]
    )

    static let penguins: [LevelDefinition] = make(
        world: .penguins,
        missions: [
            (.allLooking, .easy),
            (.nobodyBlinking, .easy),
            (.noOverlap, .medium),
            (.twoJumping, .medium),
            (.allStill, .medium),
            (.catchJumper(.scoop), .medium),
            (.allLooking, .hard),
            (.twoJumping, .hard),
        ]
    )

    static func levels(for world: WorldID) -> [LevelDefinition] {
        switch world {
        case .cafe: cafe
        case .penguins: penguins
        }
    }

    static func level(world: WorldID, index: Int) -> LevelDefinition {
        let list = levels(for: world)
        return list[min(max(0, index), list.count - 1)]
    }

    static func nextPlayable(progress: ProgressState) -> (world: WorldID, index: Int) {
        if let cafe = firstIncomplete(world: .cafe, progress: progress) {
            return (.cafe, cafe)
        }
        if progress.penguinsUnlocked, let penguins = firstIncomplete(world: .penguins, progress: progress) {
            return (.penguins, penguins)
        }
        return (.cafe, max(0, cafe.count - 1))
    }

    static func firstIncomplete(world: WorldID, progress: ProgressState) -> Int? {
        let list = levels(for: world)
        return list.first(where: { progress.stars(for: $0.id) == 0 })?.index
    }

    private static func make(
        world: WorldID,
        missions: [(Mission, Difficulty)]
    ) -> [LevelDefinition] {
        missions.enumerated().map { index, pair in
            LevelDefinition(world: world, index: index, mission: pair.0, difficulty: pair.1)
        }
    }
}

struct ProgressState: Codable, Equatable, Sendable {
    var starsByLevel: [String: Int]
    var cafeCompletions: Int
    var penguinCompletions: Int
    var hapticsEnabled: Bool
    var soundEnabled: Bool
    var hintFlashEnabled: Bool

    static let fresh = ProgressState(
        starsByLevel: [:],
        cafeCompletions: 0,
        penguinCompletions: 0,
        hapticsEnabled: true,
        soundEnabled: true,
        hintFlashEnabled: false
    )

    func stars(for levelID: String) -> Int {
        starsByLevel[levelID, default: 0]
    }

    var penguinsUnlocked: Bool {
        cafeCompletions >= 4
    }

    mutating func recordSuccess(level: LevelDefinition, stars: Int) {
        let previous = starsByLevel[level.id, default: 0]
        starsByLevel[level.id] = max(previous, stars)
        if previous == 0 {
            switch level.world {
            case .cafe: cafeCompletions += 1
            case .penguins: penguinCompletions += 1
            }
        }
    }

    func isUnlocked(_ world: WorldID) -> Bool {
        switch world {
        case .cafe: true
        case .penguins: penguinsUnlocked
        }
    }

    func isLevelUnlocked(_ level: LevelDefinition) -> Bool {
        guard isUnlocked(level.world) else { return false }
        if level.index == 0 { return true }
        let previous = LevelCatalog.level(world: level.world, index: level.index - 1)
        return stars(for: previous.id) > 0
    }
}

struct CharacterVerdict: Equatable, Sendable {
    var id: CharacterID
    var looking: Bool
    var eyesOpen: Bool
    var jumping: Bool
    var covering: Bool
}

struct ShotEvaluation: Equatable, Sendable {
    var success: Bool
    var score: Int
    var stars: Int
    var title: String
    var caption: String
    var notes: [String]
    var verdicts: [CharacterVerdict]
}

struct CapturedPhoto: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var createdAt: Date
    var world: WorldID
    var levelIndex: Int
    var missionPrompt: String
    var success: Bool
    var score: Int
    var stars: Int
    var caption: String
    var filename: String
}
