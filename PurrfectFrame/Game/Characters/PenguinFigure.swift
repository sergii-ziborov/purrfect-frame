import SwiftUI

struct PenguinFigure: View {
    var id: CharacterID
    var pose: Pose

    var body: some View {
        let p = id.palette
        let jumpY = -pose.jump * 50
        let squashX = 1 - pose.jump * 0.07 + pose.breath * 0.02
        let stretchY = 1 + pose.jump * 0.12 - pose.breath * 0.012
        let coverX = pose.cover * 36
        let faceSlide = pose.facing * pose.turnSign * 8
        let faceOpacity = max(0, 1 - pose.facing * 1.15)
        let height: CGFloat = id == .scoop ? 168 : (id == .pebble ? 118 : 148)

        ZStack {
            Ellipse()
                .fill(.black.opacity(0.14 * (1 - pose.jump * 0.6)))
                .frame(width: 88, height: 14)
                .offset(y: height * 0.48)

            ZStack {
                flipper(p)
                    .offset(x: -40, y: 8)
                    .rotationEffect(.degrees(-16 - pose.jump * 18))
                flipper(p)
                    .offset(x: 40 + pose.cover * 18 * pose.turnSign, y: 8 - pose.cover * 10)
                    .rotationEffect(.degrees(16 + pose.cover * 20 * pose.turnSign))

                body(p, height: height)

                HStack(spacing: 28) {
                    foot(p)
                    foot(p)
                }
                .offset(y: height * 0.42)

                head(p, faceSlide: faceSlide, faceOpacity: faceOpacity)
                    .offset(y: -height * 0.38)
            }
            .scaleEffect(x: squashX, y: stretchY)
            .offset(x: coverX * pose.turnSign, y: jumpY)
        }
        .frame(width: 170, height: 210)
        .scaleEffect(id.bodyScale)
    }

    private func body(_ p: CharacterPalette, height: CGFloat) -> some View {
        ZStack {
            Capsule()
                .fill(p.fur)
                .frame(width: id == .waddle ? 96 : 78, height: height)
                .overlay {
                    Capsule().stroke(Palette.ink.opacity(0.5), lineWidth: 3)
                }
            Capsule()
                .fill(p.belly)
                .frame(width: id == .waddle ? 58 : 46, height: height * 0.72)
                .offset(y: 8)
            if id == .scoop {
                Capsule()
                    .fill(p.accessory)
                    .frame(width: 54, height: 10)
                    .offset(y: -height * 0.18)
            }
        }
    }

    private func flipper(_ p: CharacterPalette) -> some View {
        Capsule()
            .fill(p.fur)
            .frame(width: 18, height: 54)
    }

    private func foot(_ p: CharacterPalette) -> some View {
        Capsule()
            .fill(p.nose)
            .frame(width: 26, height: 12)
    }

    @ViewBuilder
    private func head(_ p: CharacterPalette, faceSlide: CGFloat, faceOpacity: Double) -> some View {
        ZStack {
            Circle()
                .fill(p.fur)
                .frame(width: 72, height: 72)
                .overlay {
                    Circle().stroke(Palette.ink.opacity(0.5), lineWidth: 3)
                }

            Group {
                HStack(spacing: 14) {
                    penguinEye(far: pose.turnSign > 0)
                    penguinEye(far: pose.turnSign < 0)
                }
                .offset(x: faceSlide, y: -6)

                beak(p)
                    .offset(x: faceSlide * 0.5, y: 12)

                if pose.mouth == .tongue {
                    Capsule()
                        .fill(Color(red: 0.93, green: 0.45, blue: 0.50))
                        .frame(width: 8, height: 10)
                        .offset(y: 24)
                }
            }
            .opacity(faceOpacity)

            if pose.facing > 0.55 {
                Circle()
                    .fill(p.furLight.opacity(0.4))
                    .frame(width: 14, height: 18)
                    .offset(x: -pose.turnSign * 24)
                    .opacity((pose.facing - 0.55) / 0.45)
            }
        }
    }

    private func penguinEye(far: Bool) -> some View {
        let opacity = far ? max(0, 1 - pose.facing * 1.7) : max(0.2, 1 - pose.facing * 0.3)
        return ZStack {
            Circle().fill(.white).frame(width: 16, height: 16)
            Circle().fill(Color(red: 0.12, green: 0.12, blue: 0.14)).frame(width: 8, height: 8)
            Circle().fill(.white).frame(width: 3, height: 3).offset(x: 2, y: -2)
        }
        .scaleEffect(x: 1, y: max(0.08, 1 - pose.blink))
        .opacity(opacity)
    }

    private func beak(_ p: CharacterPalette) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(p.nose)
                .frame(width: pose.mouth == .open ? 16 : 18, height: pose.mouth == .open ? 14 : 10)
            if pose.mouth == .open {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Palette.ink.opacity(0.55))
                    .frame(width: 10, height: 6)
                    .offset(y: 2)
            }
        }
    }
}

