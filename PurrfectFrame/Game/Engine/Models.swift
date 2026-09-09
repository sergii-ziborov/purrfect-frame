import Foundation
import SwiftUI

enum Species: String, Codable, CaseIterable, Sendable {
    case cat
    case penguin
    case dog
    case rabbit
}

enum WorldID: String, Codable, CaseIterable, Identifiable, Sendable {
    case cafe
    case penguins
    case dogs
    case rabbits

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cafe: "Cat Café"
        case .penguins: "Penguin Parade"
        case .dogs: "Dog Studio"
        case .rabbits: "Rabbit Garden"
        }
    }

    var subtitle: String {
        switch self {
        case .cafe: "Warm light, worse timing."
        case .penguins: "One silhouette. Many opinions."
        case .dogs: "Good dogs. Terrible timing."
        case .rabbits: "Stillness is a rumour."
        }
    }

    var species: Species {
        switch self {
        case .cafe: .cat
        case .penguins: .penguin
        case .dogs: .dog
        case .rabbits: .rabbit
        }
    }

    var backgrounds: [String] {
        switch self {
        case .cafe: ["CafeBackground", "CafeNight", "CafeGarden"]
        case .penguins: ["PenguinBackground", "PenguinIce"]
        case .dogs: ["DogStudio", "DogPark"]
        case .rabbits: ["RabbitGarden", "RabbitBurrow"]
        }
    }

    var backgroundAsset: String { backgrounds[0] }

    func background(for levelIndex: Int) -> String {
        backgrounds[abs(levelIndex) % backgrounds.count]
    }

    var caption: String {
        switch self {
        case .cafe: "LIFE IS BETTER WITH CATS"
        case .penguins: "HUDDLE UP"
        case .dogs: "WHO'S A GOOD SHOT"
        case .rabbits: "QUIET, PLEASE"
        }
    }
}

enum CharacterID: String, Codable, CaseIterable, Identifiable, Sendable {
    case mochi, nori, butter, ink
    case pip, waddle, scoop, pebble
    case biscuit, pepper, maple, scout
    case clover, hazel, fig, thistle

    var id: String { rawValue }

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var species: Species {
        switch self {
        case .mochi, .nori, .butter, .ink: .cat
        case .pip, .waddle, .scoop, .pebble: .penguin
        case .biscuit, .pepper, .maple, .scout: .dog
        case .clover, .hazel, .fig, .thistle: .rabbit
        }
    }

    var personality: Personality {
        switch self {
        case .nori, .pip, .biscuit, .clover: .blinker
        case .mochi, .pebble, .scout, .hazel: .turner
        case .butter, .scoop, .maple, .fig: .jumper
        case .ink, .waddle, .pepper, .thistle: .coverer
        }
    }

    var coverTarget: CharacterID? {
        switch self {
        case .ink: .nori
        case .waddle: .pip
        case .mochi: .butter
        case .scoop: .pebble
        case .pepper: .biscuit
        case .thistle: .clover
        default: nil
        }
    }

    static let cafeCast: [CharacterID] = [.mochi, .nori, .butter, .ink]
    static let penguinCast: [CharacterID] = [.pip, .waddle, .scoop, .pebble]
    static let dogCast: [CharacterID] = [.biscuit, .pepper, .maple, .scout]
    static let rabbitCast: [CharacterID] = [.clover, .hazel, .fig, .thistle]

    static func cast(for world: WorldID) -> [CharacterID] {
        switch world {
        case .cafe: cafeCast
        case .penguins: penguinCast
        case .dogs: dogCast
        case .rabbits: rabbitCast
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
    var yawn: Double
    var paw: Double
    var derp: Double

    static let cameraReady = Pose(
        facing: 0, turnSign: 1, blink: 0, jump: 0, cover: 0,
        mouth: .smile, breath: 0.4, yawn: 0, paw: 0, derp: 0
    )

    var isLooking: Bool { facing < 0.28 }
    var eyesOpen: Bool { blink < 0.45 && yawn < 0.45 }
    var isJumping: Bool { jump > 0.45 }
    var isCovering: Bool { cover > 0.4 }
    var isYawning: Bool { yawn > 0.45 }
    var isWaving: Bool { paw > 0.45 }
}

enum Mission: Equatable, Codable, Hashable, Sendable {
    case allLooking
    case twoJumping
    case noOverlap
    case nobodyBlinking
    case catchJumper(CharacterID)
    case allStill
    case catchYawn(CharacterID)
    case catchWave(CharacterID)
    case nobodyYawning

    var prompt: String {
        switch self {
        case .allLooking: "Get all 4 looking"
        case .twoJumping: "Catch two in mid-air"
        case .noOverlap: "No overlapping faces"
        case .nobodyBlinking: "Nobody blinking"
        case .catchJumper(let id): "Catch \(id.displayName) in a jump"
        case .allStill: "Everyone sitting still"
        case .catchYawn(let id): "Catch \(id.displayName) yawning"
        case .catchWave(let id): "Catch \(id.displayName) waving"
        case .nobodyYawning: "No yawns in the shot"
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
        case .catchYawn(let id): "\(id.displayName) mid-yawn. The others looking."
        case .catchWave(let id): "\(id.displayName) with a paw up."
        case .nobodyYawning: "Everyone awake. No yawns."
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
            (.catchYawn(.nori), .medium),
            (.catchWave(.mochi), .medium),
            (.nobodyYawning, .medium),
            (.allLooking, .hard),
            (.noOverlap, .hard),
            (.twoJumping, .hard),
            (.nobodyBlinking, .hard),
            (.catchYawn(.ink), .hard),
        ]
    )

    static let dogs: [LevelDefinition] = make(
        world: .dogs,
        missions: [
            (.allLooking, .easy),
            (.nobodyBlinking, .easy),
            (.catchWave(.biscuit), .medium),
            (.noOverlap, .medium),
            (.twoJumping, .medium),
            (.catchJumper(.maple), .medium),
            (.allStill, .hard),
            (.nobodyYawning, .hard),
        ]
    )

    static let rabbits: [LevelDefinition] = make(
        world: .rabbits,
        missions: [
            (.allLooking, .easy),
            (.nobodyBlinking, .easy),
            (.noOverlap, .medium),
            (.catchYawn(.clover), .medium),
            (.twoJumping, .medium),
            (.catchWave(.hazel), .hard),
            (.allLooking, .hard),
            (.nobodyYawning, .hard),
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
            (.catchWave(.waddle), .medium),
            (.catchYawn(.pip), .medium),
            (.allLooking, .hard),
            (.twoJumping, .hard),
            (.nobodyYawning, .hard),
            (.catchWave(.pebble), .hard),
        ]
    )

    static func levels(for world: WorldID) -> [LevelDefinition] {
        switch world {
        case .cafe: cafe
        case .penguins: penguins
        case .dogs: dogs
        case .rabbits: rabbits
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
        if progress.dogsUnlocked, let dogs = firstIncomplete(world: .dogs, progress: progress) {
            return (.dogs, dogs)
        }
        if progress.rabbitsUnlocked, let rabbits = firstIncomplete(world: .rabbits, progress: progress) {
            return (.rabbits, rabbits)
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
    var dogCompletions: Int
    var rabbitCompletions: Int
    var hapticsEnabled: Bool
    var soundEnabled: Bool
    var hintFlashEnabled: Bool

    static let fresh = ProgressState(
        starsByLevel: [:],
        cafeCompletions: 0,
        penguinCompletions: 0,
        dogCompletions: 0,
        rabbitCompletions: 0,
        hapticsEnabled: true,
        soundEnabled: true,
        hintFlashEnabled: false
    )

    enum CodingKeys: String, CodingKey {
        case starsByLevel, cafeCompletions, penguinCompletions
        case dogCompletions, rabbitCompletions
        case hapticsEnabled, soundEnabled, hintFlashEnabled
    }

    init(
        starsByLevel: [String: Int],
        cafeCompletions: Int,
        penguinCompletions: Int,
        dogCompletions: Int,
        rabbitCompletions: Int,
        hapticsEnabled: Bool,
        soundEnabled: Bool,
        hintFlashEnabled: Bool
    ) {
        self.starsByLevel = starsByLevel
        self.cafeCompletions = cafeCompletions
        self.penguinCompletions = penguinCompletions
        self.dogCompletions = dogCompletions
        self.rabbitCompletions = rabbitCompletions
        self.hapticsEnabled = hapticsEnabled
        self.soundEnabled = soundEnabled
        self.hintFlashEnabled = hintFlashEnabled
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        starsByLevel = try c.decodeIfPresent([String: Int].self, forKey: .starsByLevel) ?? [:]
        cafeCompletions = try c.decodeIfPresent(Int.self, forKey: .cafeCompletions) ?? 0
        penguinCompletions = try c.decodeIfPresent(Int.self, forKey: .penguinCompletions) ?? 0
        dogCompletions = try c.decodeIfPresent(Int.self, forKey: .dogCompletions) ?? 0
        rabbitCompletions = try c.decodeIfPresent(Int.self, forKey: .rabbitCompletions) ?? 0
        hapticsEnabled = try c.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? true
        soundEnabled = try c.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? true
        hintFlashEnabled = try c.decodeIfPresent(Bool.self, forKey: .hintFlashEnabled) ?? false
    }

    func stars(for levelID: String) -> Int {
        starsByLevel[levelID, default: 0]
    }

    var penguinsUnlocked: Bool { cafeCompletions >= 4 }
    var dogsUnlocked: Bool { penguinCompletions >= 3 || cafeCompletions >= 8 }
    var rabbitsUnlocked: Bool { dogCompletions >= 3 }

    mutating func recordSuccess(level: LevelDefinition, stars: Int) {
        let previous = starsByLevel[level.id, default: 0]
        starsByLevel[level.id] = max(previous, stars)
        if previous == 0 {
            switch level.world {
            case .cafe: cafeCompletions += 1
            case .penguins: penguinCompletions += 1
            case .dogs: dogCompletions += 1
            case .rabbits: rabbitCompletions += 1
            }
        }
    }

    func isUnlocked(_ world: WorldID) -> Bool {
        switch world {
        case .cafe: true
        case .penguins: penguinsUnlocked
        case .dogs: dogsUnlocked
        case .rabbits: rabbitsUnlocked
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
