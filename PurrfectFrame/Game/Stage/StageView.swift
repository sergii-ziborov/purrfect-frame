import SwiftUI

struct StageSlot: Identifiable {
    var id: CharacterID
    var x: CGFloat
    var y: CGFloat
    var z: Double
    var scale: CGFloat
}

enum StageLayout {
    static func slots(for world: WorldID) -> [StageSlot] {
        switch world {
        case .cafe:
            [
                StageSlot(id: .mochi, x: -0.28, y: -0.16, z: 1, scale: 0.92),
                StageSlot(id: .butter, x: 0.30, y: -0.20, z: 1.1, scale: 1.0),
                StageSlot(id: .nori, x: -0.18, y: 0.22, z: 2, scale: 1.04),
                StageSlot(id: .ink, x: 0.20, y: 0.24, z: 3, scale: 0.98),
            ]
        case .penguins:
            [
                StageSlot(id: .pip, x: -0.26, y: 0.18, z: 2, scale: 0.92),
                StageSlot(id: .waddle, x: 0.08, y: 0.22, z: 3, scale: 1.05),
                StageSlot(id: .scoop, x: 0.30, y: -0.12, z: 1.2, scale: 1.0),
                StageSlot(id: .pebble, x: -0.08, y: -0.18, z: 1, scale: 0.82),
            ]
        case .dogs:
            [
                StageSlot(id: .biscuit, x: -0.26, y: -0.12, z: 1, scale: 1.02),
                StageSlot(id: .scout, x: 0.28, y: -0.14, z: 1.1, scale: 1.0),
                StageSlot(id: .pepper, x: -0.16, y: 0.24, z: 3, scale: 0.88),
                StageSlot(id: .maple, x: 0.18, y: 0.22, z: 2, scale: 0.92),
            ]
        case .rabbits:
            [
                StageSlot(id: .clover, x: -0.24, y: 0.16, z: 2, scale: 0.95),
                StageSlot(id: .hazel, x: 0.22, y: 0.18, z: 3, scale: 1.0),
                StageSlot(id: .fig, x: -0.10, y: -0.16, z: 1, scale: 0.90),
                StageSlot(id: .thistle, x: 0.28, y: -0.14, z: 1.1, scale: 0.96),
            ]
        case .foxes:
            [
                StageSlot(id: .ember, x: -0.26, y: 0.18, z: 2, scale: 0.96),
                StageSlot(id: .rust, x: 0.24, y: 0.16, z: 3, scale: 1.0),
                StageSlot(id: .fern, x: -0.12, y: -0.16, z: 1, scale: 0.90),
                StageSlot(id: .soot, x: 0.28, y: -0.14, z: 1.1, scale: 0.94),
            ]
        case .owls:
            [
                StageSlot(id: .hoot, x: -0.24, y: 0.14, z: 2, scale: 0.92),
                StageSlot(id: .velvet, x: 0.22, y: 0.16, z: 3, scale: 1.0),
                StageSlot(id: .parchment, x: -0.10, y: -0.18, z: 1, scale: 0.88),
                StageSlot(id: .nib, x: 0.28, y: -0.12, z: 1.2, scale: 1.04),
            ]
        }
    }
}

struct StageView: View {
    var world: WorldID
    var poses: [CharacterID: Pose]
    var backgroundName: String? = nil
    var showChrome: Bool = true
    var hintActive: Bool = false
    var levelIndex: Int = 0

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            ZStack {
                Image(backgroundName ?? world.background(for: levelIndex))
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                    .id(backgroundName ?? world.background(for: levelIndex))

                LinearGradient(
                    colors: [.black.opacity(0.08), .clear, .black.opacity(0.18)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                ForEach(StageLayout.slots(for: world)) { slot in
                    let pose = poses[slot.id] ?? .cameraReady
                    CreatureView(id: slot.id, pose: pose)
                        .scaleEffect(slot.scale * min(width / 390, height / 620))
                        .position(
                            x: width * (0.5 + slot.x) + pose.cover * pose.turnSign * 8,
                            y: height * (0.52 + slot.y)
                        )
                        .zIndex(slot.z + pose.cover * 2 + pose.jump)
                }

                Text(world.caption)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.28), in: Capsule())
                    .position(x: width * 0.5, y: height * 0.90)

                if showChrome {
                    ViewfinderCorners(active: hintActive)
                        .padding(10)
                }
            }
        }
        .clipped()
    }
}
