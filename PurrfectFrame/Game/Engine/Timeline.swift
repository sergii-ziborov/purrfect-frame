import Foundation

struct Channel: Equatable, Sendable {
    struct Key: Equatable, Sendable {
        var time: TimeInterval
        var value: Double
    }

    var keys: [Key]

    static func constant(_ value: Double) -> Channel {
        Channel(keys: [Key(time: 0, value: value)])
    }

    mutating func addHold(_ range: ClosedRange<TimeInterval>, value: Double, ease: TimeInterval = 0.16) {
        keys.append(Key(time: max(0, range.lowerBound - ease), value: value))
        keys.append(Key(time: range.lowerBound, value: value))
        keys.append(Key(time: range.upperBound, value: value))
        keys.append(Key(time: range.upperBound + ease, value: 0))
    }

    mutating func addPulse(at start: TimeInterval, duration: TimeInterval, peak: Double, hold: TimeInterval = 0) {
        let rise = max(0.08, (duration - hold) * 0.42)
        keys.append(Key(time: start, value: 0))
        keys.append(Key(time: start + rise, value: peak))
        if hold > 0 {
            keys.append(Key(time: start + rise + hold, value: peak))
        }
        keys.append(Key(time: start + duration, value: 0))
    }

    func sample(_ time: TimeInterval, loop: TimeInterval) -> Double {
        let t = Self.wrap(time, loop: loop)
        let sorted = keys.sorted { $0.time < $1.time }
        guard let first = sorted.first else { return 0 }
        guard sorted.count > 1, let last = sorted.last else { return first.value }

        if t <= first.time {
            return Self.lerp(last.value, first.value, Self.smooth(t, last.time - loop, first.time))
        }
        if t >= last.time {
            return Self.lerp(last.value, first.value, Self.smooth(t, last.time, first.time + loop))
        }
        for index in 0..<(sorted.count - 1) {
            let a = sorted[index]
            let b = sorted[index + 1]
            if t >= a.time && t <= b.time {
                return Self.lerp(a.value, b.value, Self.smooth(t, a.time, b.time))
            }
        }
        return first.value
    }

    private static func wrap(_ time: TimeInterval, loop: TimeInterval) -> TimeInterval {
        let t = time.truncatingRemainder(dividingBy: loop)
        return t < 0 ? t + loop : t
    }

    private static func lerp(_ a: Double, _ b: Double, _ u: Double) -> Double {
        a + (b - a) * min(max(u, 0), 1)
    }

    private static func smooth(_ t: TimeInterval, _ a: TimeInterval, _ b: TimeInterval) -> Double {
        guard b > a else { return 0 }
        let u = (t - a) / (b - a)
        return u * u * (3 - 2 * u)
    }
}

struct CharacterClip: Equatable, Sendable {
    var facing: Channel
    var blink: Channel
    var jump: Channel
    var cover: Channel
    var yawn: Channel
    var paw: Channel
    var derp: Channel
    var turnSign: Double

    func pose(at time: TimeInterval, loop: TimeInterval, breath: Double) -> Pose {
        let facingValue = min(max(facing.sample(time, loop: loop), 0), 1)
        let blinkValue = min(max(blink.sample(time, loop: loop), 0), 1)
        let jumpValue = min(max(jump.sample(time, loop: loop), 0), 1)
        let coverValue = min(max(cover.sample(time, loop: loop), 0), 1)
        let yawnValue = min(max(yawn.sample(time, loop: loop), 0), 1)
        let pawValue = min(max(paw.sample(time, loop: loop), 0), 1)
        let derpValue = min(max(derp.sample(time, loop: loop), 0), 1)
        return Pose(
            facing: facingValue,
            turnSign: turnSign,
            blink: blinkValue,
            jump: jumpValue,
            cover: coverValue,
            mouth: Self.mouth(
                facing: facingValue, blink: blinkValue, jump: jumpValue,
                cover: coverValue, yawn: yawnValue, derp: derpValue
            ),
            breath: breath,
            yawn: yawnValue,
            paw: pawValue,
            derp: derpValue
        )
    }

    private static func mouth(
        facing: Double, blink: Double, jump: Double, cover: Double, yawn: Double, derp: Double
    ) -> Mouth {
        if yawn > 0.45 { return .open }
        if cover > 0.5 { return .tongue }
        if jump > 0.5 { return .open }
        if derp > 0.45 { return .derp }
        if facing > 0.55 { return .derp }
        if blink > 0.55 { return .flat }
        return .smile
    }
}

struct RoundTimeline: Equatable, Sendable {
    var loopDuration: TimeInterval
    var successWindow: ClosedRange<TimeInterval>
    var clips: [CharacterID: CharacterClip]
    var mission: Mission
    var cast: [CharacterID]

    func snapshot(at time: TimeInterval) -> [CharacterID: Pose] {
        var poses: [CharacterID: Pose] = [:]
        poses.reserveCapacity(cast.count)
        for (index, id) in cast.enumerated() {
            let breath = 0.5 + 0.5 * sin(time * 2.35 + Double(index) * 1.1)
            poses[id] = clips[id]?.pose(at: time, loop: loopDuration, breath: breath) ?? .cameraReady
        }
        return poses
    }

    func wrappedTime(_ time: TimeInterval) -> TimeInterval {
        let t = time.truncatingRemainder(dividingBy: loopDuration)
        return t < 0 ? t + loopDuration : t
    }

    func isDeclaredSuccessWindow(_ time: TimeInterval) -> Bool {
        successWindow.contains(wrappedTime(time))
    }
}

enum EventKind {
    case blink, turn, jump, cover, yawn, paw, derp

    var duration: TimeInterval {
        switch self {
        case .blink: 0.28
        case .turn: 1.35
        case .jump: 0.72
        case .cover: 0.95
        case .yawn: 1.05
        case .paw: 0.85
        case .derp: 0.70
        }
    }
}

enum RoundScheme: String, CaseIterable, Sendable {
    case scatter
    case blinkWave
    case turnOff
    case jumpRelay
    case yawnRipple
    case huddle
    case pawParty
}

enum TimelineBuilder {
    static let loopDuration: TimeInterval = 11.0
    static let introEnd: TimeInterval = 0.62

    static func build(
        mission: Mission,
        cast: [CharacterID],
        difficulty: Difficulty,
        seed: UInt64
    ) -> RoundTimeline {
        var rng = SeededRNG(seed: seed)
        let windowDuration = difficulty.windowDuration
        let latestStart = loopDuration - windowDuration - 1.15
        let windowStart = rng.next(in: 2.15...max(2.15, latestStart))
        let window = windowStart...(windowStart + windowDuration)
        let forbidden = (window.lowerBound - 0.42)...(window.upperBound + 0.42)

        let success = successPoses(mission: mission, cast: cast, rng: &rng)
        var clips: [CharacterID: CharacterClip] = [:]

        let scheme = RoundScheme.allCases[rng.nextInt(in: 0...(RoundScheme.allCases.count - 1))]

        for (index, id) in cast.enumerated() {
            let target = success[id] ?? .cameraReady
            var facing = Channel.constant(0)
            var blink = Channel.constant(0)
            var jump = Channel.constant(0)
            var cover = Channel.constant(0)
            var yawn = Channel.constant(0)
            var paw = Channel.constant(0)
            var derp = Channel.constant(0)
            let turnSign = rng.nextBool() ? 1.0 : -1.0

            facing.addHold(0...introEnd, value: 0)
            blink.addHold(0...introEnd, value: 0)
            jump.addHold(0...introEnd, value: 0)
            cover.addHold(0...introEnd, value: 0)
            yawn.addHold(0...introEnd, value: 0)
            paw.addHold(0...introEnd, value: 0)
            derp.addHold(0...introEnd, value: 0)

            facing.addHold(window, value: target.facing)
            blink.addHold(window, value: target.blink)
            jump.addHold(window, value: target.jump)
            cover.addHold(window, value: target.cover)
            yawn.addHold(window, value: target.yawn)
            paw.addHold(window, value: target.paw)
            derp.addHold(window, value: target.derp)

            let kinds = chaosPool(personality: id.personality, mission: mission, scheme: scheme)
            for _ in 0..<difficulty.chaosCount {
                let kind = rng.pick(kinds)
                guard let start = slot(
                    rng: &rng,
                    duration: kind.duration,
                    forbidden: [forbidden, 0...introEnd]
                ) else { continue }
                apply(kind, at: start, facing: &facing, blink: &blink, jump: &jump, cover: &cover, yawn: &yawn, paw: &paw, derp: &derp)
            }

            applyScheme(
                scheme,
                index: index,
                castCount: cast.count,
                window: window,
                rng: &rng,
                facing: &facing,
                blink: &blink,
                jump: &jump,
                cover: &cover,
                yawn: &yawn,
                paw: &paw,
                derp: &derp
            )

            clips[id] = CharacterClip(
                facing: facing,
                blink: blink,
                jump: jump,
                cover: cover,
                yawn: yawn,
                paw: paw,
                derp: derp,
                turnSign: turnSign
            )
        }

        return RoundTimeline(
            loopDuration: loopDuration,
            successWindow: window,
            clips: clips,
            mission: mission,
            cast: cast
        )
    }

    static func successPoses(
        mission: Mission,
        cast: [CharacterID],
        rng: inout SeededRNG
    ) -> [CharacterID: Pose] {
        var poses: [CharacterID: Pose] = [:]
        for id in cast {
            poses[id] = .cameraReady
        }

        switch mission {
        case .allLooking, .nobodyBlinking, .noOverlap, .allStill:
            break
        case .twoJumping:
            var pool = cast
            pool.shuffle(using: &rng)
            let jumpers = Array(pool.prefix(2))
            for id in jumpers {
                poses[id]?.jump = 1
                poses[id]?.mouth = .open
            }
        case .catchJumper(let jumper):
            poses[jumper]?.jump = 1
            poses[jumper]?.mouth = .open
        case .catchYawn(let who):
            poses[who]?.yawn = 1
            poses[who]?.mouth = .open
        case .catchWave(let who):
            poses[who]?.paw = 1
        case .nobodyYawning:
            break
        }
        return poses
    }

    private static func chaosPool(
        personality: Personality,
        mission: Mission,
        scheme: RoundScheme
    ) -> [EventKind] {
        var pool: [EventKind] = [.blink, .blink, .turn, .jump, .cover, .yawn, .paw, .derp]
        switch personality {
        case .blinker: pool += [.blink, .blink, .blink, .yawn]
        case .turner: pool += [.turn, .turn, .derp]
        case .jumper: pool += [.jump, .jump, .paw]
        case .coverer: pool += [.cover, .cover, .paw]
        }
        switch mission {
        case .allLooking: pool += [.turn, .blink, .cover, .derp]
        case .twoJumping, .catchJumper, .allStill: pool += [.jump, .jump]
        case .noOverlap: pool += [.cover, .cover]
        case .nobodyBlinking: pool += [.blink, .blink, .yawn]
        case .catchYawn, .nobodyYawning: pool += [.yawn, .yawn]
        case .catchWave: pool += [.paw, .paw]
        }
        switch scheme {
        case .scatter: break
        case .blinkWave: pool += [.blink, .blink]
        case .turnOff: pool += [.turn, .turn]
        case .jumpRelay: pool += [.jump]
        case .yawnRipple: pool += [.yawn, .yawn]
        case .huddle: pool += [.cover, .cover]
        case .pawParty: pool += [.paw, .paw]
        }
        return pool
    }

    private static func apply(
        _ kind: EventKind,
        at start: TimeInterval,
        facing: inout Channel,
        blink: inout Channel,
        jump: inout Channel,
        cover: inout Channel,
        yawn: inout Channel,
        paw: inout Channel,
        derp: inout Channel
    ) {
        switch kind {
        case .blink:
            blink.addPulse(at: start, duration: kind.duration, peak: 1, hold: 0.06)
        case .turn:
            facing.addPulse(at: start, duration: kind.duration, peak: 1, hold: 0.45)
        case .jump:
            jump.addPulse(at: start, duration: kind.duration, peak: 1, hold: 0.12)
        case .cover:
            cover.addPulse(at: start, duration: kind.duration, peak: 1, hold: 0.28)
        case .yawn:
            yawn.addPulse(at: start, duration: kind.duration, peak: 1, hold: 0.28)
        case .paw:
            paw.addPulse(at: start, duration: kind.duration, peak: 1, hold: 0.22)
        case .derp:
            derp.addPulse(at: start, duration: kind.duration, peak: 1, hold: 0.18)
        }
    }

    private static func applyScheme(
        _ scheme: RoundScheme,
        index: Int,
        castCount: Int,
        window: ClosedRange<TimeInterval>,
        rng: inout SeededRNG,
        facing: inout Channel,
        blink: inout Channel,
        jump: inout Channel,
        cover: inout Channel,
        yawn: inout Channel,
        paw: inout Channel,
        derp: inout Channel
    ) {
        let afterIntro = introEnd + 0.2
        let beforeWindow = max(afterIntro, window.lowerBound - 1.6)
        guard beforeWindow > afterIntro + 0.3 else { return }
        let stagger = Double(index) * 0.32
        switch scheme {
        case .scatter:
            derp.addPulse(at: rng.next(in: afterIntro...beforeWindow), duration: EventKind.derp.duration, peak: 0.85, hold: 0.1)
        case .blinkWave:
            blink.addPulse(at: afterIntro + stagger, duration: EventKind.blink.duration, peak: 1, hold: 0.05)
        case .turnOff:
            facing.addPulse(at: afterIntro + stagger, duration: 1.1, peak: 1, hold: 0.3)
        case .jumpRelay:
            jump.addPulse(at: afterIntro + stagger * 1.4, duration: EventKind.jump.duration, peak: 1, hold: 0.08)
        case .yawnRipple:
            yawn.addPulse(at: afterIntro + stagger, duration: EventKind.yawn.duration, peak: 1, hold: 0.2)
        case .huddle:
            if index % 2 == 1 {
                cover.addPulse(at: afterIntro + 0.15, duration: 1.1, peak: 1, hold: 0.35)
            }
        case .pawParty:
            paw.addPulse(at: afterIntro + stagger, duration: EventKind.paw.duration, peak: 1, hold: 0.2)
        }
    }

    private static func slot(
        rng: inout SeededRNG,
        duration: TimeInterval,
        forbidden: [ClosedRange<TimeInterval>]
    ) -> TimeInterval? {
        for _ in 0..<28 {
            let start = rng.next(in: 0.7...(loopDuration - duration - 0.35))
            let span = start...(start + duration)
            if forbidden.allSatisfy({ !overlaps($0, span) }) {
                return start
            }
        }
        return nil
    }

    private static func overlaps(_ a: ClosedRange<TimeInterval>, _ b: ClosedRange<TimeInterval>) -> Bool {
        a.lowerBound <= b.upperBound && b.lowerBound <= a.upperBound
    }
}

