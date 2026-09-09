import SwiftUI

struct SpriteCreatureView: View {
    var id: CharacterID
    var pose: Pose

    private var prefix: String {
        id.rawValue.prefix(1).uppercased() + id.rawValue.dropFirst()
    }

    /// Turn sprites were drawn looking a particular way; flip when the timeline disagrees.
    private var turnFacesRight: Bool {
        switch id {
        case .mochi, .butter, .waddle, .scoop: true
        case .nori, .ink, .pip, .pebble: false
        }
    }

    var body: some View {
        let jumpY = -pose.jump * 52
        let squash = 1 - pose.jump * 0.05 + pose.breath * 0.012
        let stretch = 1 + pose.jump * 0.07 - pose.breath * 0.01
        let coverX = pose.cover * 30 * pose.turnSign
        let flipTurn = (pose.turnSign > 0) != turnFacesRight

        ZStack {
            Ellipse()
                .fill(.black.opacity(0.16 * (1 - pose.jump * 0.65)))
                .frame(width: 96, height: 16)
                .offset(y: 82)

            ZStack {
                sprite("Idle")
                sprite("Blink").opacity(min(1, pose.blink * 1.15))
                sprite("Turn")
                    .scaleEffect(x: flipTurn ? -1 : 1, y: 1)
                    .opacity(min(1, pose.facing * 1.2))
                if id.species == .cat {
                    sprite("Cover").opacity(min(1, pose.cover * 1.15))
                }
                sprite("Jump").opacity(min(1, pose.jump * 1.2))
            }
            .scaleEffect(x: squash, y: stretch)
            .offset(x: coverX, y: jumpY)
        }
        .frame(width: 200, height: 230)
        .scaleEffect(id.bodyScale)
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
