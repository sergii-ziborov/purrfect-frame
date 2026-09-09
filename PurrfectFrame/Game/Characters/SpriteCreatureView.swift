import SwiftUI

struct SpriteCreatureView: View {
    var id: CharacterID
    var pose: Pose

    private var prefix: String {
        id.rawValue.prefix(1).uppercased() + id.rawValue.dropFirst()
    }

    var body: some View {
        let jumpY = -pose.jump * 52
        let squash = 1 - pose.jump * 0.05 + pose.breath * 0.012
        let stretch = 1 + pose.jump * 0.07 - pose.breath * 0.01
        let coverX = pose.cover * 30 * pose.turnSign

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
            .offset(x: coverX, y: jumpY)
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
        let cover = id.species == .cat ? take(pose.cover) : 0
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
