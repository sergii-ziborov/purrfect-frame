import SwiftUI

struct SpriteCreatureView: View {
    var id: CharacterID
    var pose: Pose

    private var prefix: String {
        id.rawValue.prefix(1).uppercased() + id.rawValue.dropFirst()
    }

    var body: some View {
        let jumpY = -pose.jump * 52
        let squash = 1 - pose.jump * 0.05 + pose.breath * 0.018
        let stretch = 1 + pose.jump * 0.07 - pose.breath * 0.014
        let coverX = pose.cover * 30 * pose.turnSign
        let sway = (pose.breath - 0.5) * 5 + pose.derp * 7 * pose.turnSign
        let nod = pose.yawn * 6 - pose.paw * 3

        ZStack {
            Ellipse()
                .fill(.black.opacity(0.16 * (1 - pose.jump * 0.65)))
                .frame(width: 96, height: 16)
                .offset(y: 82)

            ZStack {
                ForEach(layers, id: \.name) { layer in
                    sprite(layer.name)
                        .opacity(layer.weight)
                }
            }
            .compositingGroup()
            .scaleEffect(x: squash, y: stretch)
            .rotationEffect(.degrees(sway))
            .rotationEffect(.degrees(nod), anchor: .bottom)
            .offset(x: coverX + pose.derp * 5 * pose.turnSign, y: jumpY)
        }
        .frame(width: 200, height: 230)
        .scaleEffect(id.bodyScale)
    }

    private struct Layer: Equatable {
        var name: String
        var weight: Double
    }

    /// One body on screen. Idle yields to whatever action is actually happening,
    /// so a turn or blink never sits on top of a second copy of the same cat.
    private var layers: [Layer] {
        var remaining = 1.0
        func take(_ amount: Double) -> Double {
            let weight = min(max(amount, 0), remaining)
            remaining -= weight
            return weight
        }
        let jump = take(pose.jump)
        let cover = take(pose.cover)
        let turn = take(pose.facing)
        let yawn = take(pose.yawn)
        let paw = take(pose.paw)
        let derp = take(pose.derp)
        let blink = take(pose.blink)
        let idle = remaining
        return [
            Layer(name: "Idle", weight: idle),
            Layer(name: "Blink", weight: blink),
            Layer(name: "Derp", weight: derp),
            Layer(name: "Paw", weight: paw),
            Layer(name: "Yawn", weight: yawn),
            Layer(name: "Turn", weight: turn),
            Layer(name: "Cover", weight: cover),
            Layer(name: "Jump", weight: jump),
        ].filter { $0.weight > 0.03 }
    }

    private func sprite(_ suffix: String) -> some View {
        Image("\(prefix)\(suffix)")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: 200, height: 230)
    }
}

struct CreatureView: View {
    var id: CharacterID
    var pose: Pose

    var body: some View {
        SpriteCreatureView(id: id, pose: pose)
            .accessibilityLabel(id.displayName)
    }
}

enum IdleMotion {
    static func pose(id: CharacterID, at time: TimeInterval, index: Int) -> Pose {
        var pose = Pose.cameraReady
        pose.turnSign = index % 2 == 0 ? 1 : -1
        pose.breath = 0.5 + 0.5 * sin(time * 0.95 + Double(index) * 1.15)
        pose.blink = pulse((time + Double(index) * 1.35).truncatingRemainder(dividingBy: 5.2), duration: 1.2)
        pose.paw = pulse((time + Double(index) * 2.5 + 1.4).truncatingRemainder(dividingBy: 8.8), duration: 1.7) * 0.95
        if index == 1 || index == 3 {
            pose.yawn = pulse((time + Double(index) * 1.9 + 3.2).truncatingRemainder(dividingBy: 13.5), duration: 2.15) * 0.92
        }
        if index == 0 || index == 2 {
            pose.derp = pulse((time + Double(index) * 2.8 + 2.0).truncatingRemainder(dividingBy: 11.0), duration: 1.55) * 0.88
        }
        if id.personality == .turner {
            pose.facing = pulse((time + Double(index) * 1.6 + 5.0).truncatingRemainder(dividingBy: 12.4), duration: 2.2) * 0.9
        }
        _ = id
        return pose
    }

    private static func pulse(_ t: Double, duration: Double) -> Double {
        guard t >= 0, t < duration else { return 0 }
        let u = t / duration
        if u < 0.28 { return u / 0.28 }
        if u > 0.72 { return max(0, (1 - u) / 0.28) }
        return 1
    }
}
