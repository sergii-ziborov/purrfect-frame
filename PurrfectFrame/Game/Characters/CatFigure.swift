import SwiftUI

struct CharacterPalette {
    var fur: Color
    var furDark: Color
    var furLight: Color
    var belly: Color
    var innerEar: Color
    var iris: Color
    var nose: Color
    var accessory: Color
}

extension CharacterID {
    var palette: CharacterPalette {
        switch self {
        case .mochi:
            CharacterPalette(
                fur: Color(red: 0.91, green: 0.58, blue: 0.27),
                furDark: Color(red: 0.78, green: 0.42, blue: 0.16),
                furLight: Color(red: 0.98, green: 0.82, blue: 0.58),
                belly: Color(red: 0.99, green: 0.93, blue: 0.82),
                innerEar: Color(red: 0.96, green: 0.72, blue: 0.68),
                iris: Color(red: 0.82, green: 0.58, blue: 0.16),
                nose: Color(red: 0.78, green: 0.38, blue: 0.36),
                accessory: Color(red: 0.75, green: 0.22, blue: 0.22)
            )
        case .nori:
            CharacterPalette(
                fur: Color(red: 0.55, green: 0.57, blue: 0.60),
                furDark: Color(red: 0.38, green: 0.40, blue: 0.44),
                furLight: Color(red: 0.78, green: 0.80, blue: 0.82),
                belly: Color(red: 0.90, green: 0.91, blue: 0.92),
                innerEar: Color(red: 0.93, green: 0.74, blue: 0.72),
                iris: Color(red: 0.24, green: 0.55, blue: 0.38),
                nose: Color(red: 0.55, green: 0.40, blue: 0.40),
                accessory: .clear
            )
        case .butter:
            CharacterPalette(
                fur: Color(red: 0.96, green: 0.88, blue: 0.76),
                furDark: Color(red: 0.86, green: 0.74, blue: 0.58),
                furLight: Color(red: 0.99, green: 0.96, blue: 0.90),
                belly: Color(red: 0.99, green: 0.97, blue: 0.93),
                innerEar: Color(red: 0.96, green: 0.78, blue: 0.76),
                iris: Color(red: 0.36, green: 0.56, blue: 0.82),
                nose: Color(red: 0.92, green: 0.62, blue: 0.66),
                accessory: Color(red: 0.95, green: 0.55, blue: 0.62)
            )
        case .ink:
            CharacterPalette(
                fur: Color(red: 0.14, green: 0.14, blue: 0.15),
                furDark: Color(red: 0.07, green: 0.07, blue: 0.08),
                furLight: Color(red: 0.28, green: 0.28, blue: 0.30),
                belly: Color.white,
                innerEar: Color(red: 0.90, green: 0.70, blue: 0.70),
                iris: Color(red: 0.90, green: 0.74, blue: 0.18),
                nose: Color(red: 0.25, green: 0.22, blue: 0.22),
                accessory: Color(red: 0.90, green: 0.72, blue: 0.16)
            )
        case .pip, .waddle, .scoop, .pebble:
            CharacterPalette(
                fur: Color(red: 0.12, green: 0.13, blue: 0.16),
                furDark: Color(red: 0.07, green: 0.08, blue: 0.10),
                furLight: Color(red: 0.22, green: 0.24, blue: 0.28),
                belly: Color(red: 0.97, green: 0.96, blue: 0.93),
                innerEar: Color(red: 0.96, green: 0.62, blue: 0.28),
                iris: Color(red: 0.18, green: 0.18, blue: 0.20),
                nose: Color(red: 0.94, green: 0.55, blue: 0.20),
                accessory: Color(red: 0.86, green: 0.32, blue: 0.32)
            )
        default:
            CharacterPalette(
                fur: Color(red: 0.62, green: 0.48, blue: 0.32),
                furDark: Color(red: 0.42, green: 0.30, blue: 0.18),
                furLight: Color(red: 0.86, green: 0.78, blue: 0.66),
                belly: Color(red: 0.95, green: 0.92, blue: 0.88),
                innerEar: Color(red: 0.94, green: 0.72, blue: 0.70),
                iris: Color(red: 0.28, green: 0.22, blue: 0.18),
                nose: Color(red: 0.35, green: 0.22, blue: 0.18),
                accessory: Color(red: 0.25, green: 0.45, blue: 0.78)
            )
        }
    }

    var bodyScale: CGFloat {
        switch self {
        case .butter: 1.08
        case .pebble: 0.78
        case .scoop: 1.14
        case .waddle: 1.10
        case .pip: 0.90
        case .pepper, .maple: 0.90
        case .fig: 0.88
        case .clover, .hazel: 0.94
        default: 1.0
        }
    }

    var isFluffy: Bool {
        self == .butter
    }

    var hasTabby: Bool {
        self == .mochi || self == .nori
    }

    var isTuxedo: Bool {
        self == .ink
    }
}

struct CatFigure: View {
    var id: CharacterID
    var pose: Pose

    var body: some View {
        let p = id.palette
        let jumpY = -pose.jump * 56
        let squashX = 1 - pose.jump * 0.08 + pose.breath * 0.02
        let stretchY = 1 + pose.jump * 0.14 - pose.breath * 0.015
        let coverX = pose.cover * 40
        let faceSlide = pose.facing * pose.turnSign * 9
        let faceOpacity = max(0, 1 - pose.facing * 1.15)

        ZStack {
            Ellipse()
                .fill(.black.opacity(0.16 * (1 - pose.jump * 0.65)))
                .frame(width: 92, height: 16)
                .offset(y: 86)

            ZStack {
                tail(p)
                    .offset(x: -42 * pose.turnSign, y: 28)
                    .rotationEffect(.degrees(-18 * pose.turnSign + pose.jump * 12))

                body(p)
                    .offset(y: 22)

                if id == .mochi {
                    bandana(p)
                        .offset(y: -2)
                }

                raisedPaw(p)
                    .offset(
                        x: 28 * pose.turnSign + pose.cover * 22 * pose.turnSign,
                        y: 30 - pose.cover * 36 - pose.jump * 18
                    )
                    .rotationEffect(.degrees(pose.cover * 28 * pose.turnSign))
                    .opacity(0.35 + pose.cover + pose.jump * 0.4)

                head(p, faceSlide: faceSlide, faceOpacity: faceOpacity)
                    .offset(y: -38)

                if id == .ink {
                    bell(p)
                        .offset(y: 6)
                }
            }
            .scaleEffect(x: squashX, y: stretchY)
            .offset(x: coverX * pose.turnSign, y: jumpY)
        }
        .frame(width: 180, height: 210)
        .scaleEffect(id.bodyScale)
    }

    @ViewBuilder
    private func body(_ p: CharacterPalette) -> some View {
        ZStack {
            Ellipse()
                .fill(p.fur)
                .frame(width: 108, height: 86)
                .overlay {
                    Ellipse().stroke(Palette.ink.opacity(0.55), lineWidth: 3)
                }
                .overlay {
                    if id.hasTabby {
                        VStack(spacing: 10) {
                            Capsule().fill(p.furDark.opacity(0.45)).frame(width: 70, height: 8)
                            Capsule().fill(p.furDark.opacity(0.35)).frame(width: 58, height: 7)
                        }
                        .offset(y: -6)
                    }
                }
            Ellipse()
                .fill(p.belly)
                .frame(width: id.isTuxedo ? 54 : 62, height: 58)
                .offset(y: 8)
            HStack(spacing: 48) {
                paw(p)
                paw(p)
            }
            .offset(y: 40)
        }
    }

    private func paw(_ p: CharacterPalette) -> some View {
        Capsule()
            .fill(p.furLight)
            .frame(width: 22, height: 16)
            .overlay(alignment: .bottom) {
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        Capsule().fill(p.innerEar.opacity(0.7)).frame(width: 4, height: 5)
                    }
                }
                .offset(y: 2)
            }
    }

    private func raisedPaw(_ p: CharacterPalette) -> some View {
        Capsule()
            .fill(p.fur)
            .frame(width: 20, height: 36)
            .overlay(alignment: .top) {
                Circle().fill(p.furLight).frame(width: 22, height: 20)
            }
    }

    private func tail(_ p: CharacterPalette) -> some View {
        Capsule()
            .fill(p.furDark)
            .frame(width: 18, height: 64)
            .rotationEffect(.degrees(40))
    }

    @ViewBuilder
    private func head(_ p: CharacterPalette, faceSlide: CGFloat, faceOpacity: Double) -> some View {
        ZStack {
            ear(p, inner: true)
                .offset(x: -28, y: -36)
                .rotationEffect(.degrees(-18))
            ear(p, inner: true)
                .offset(x: 28, y: -36)
                .rotationEffect(.degrees(18))

            Ellipse()
                .fill(p.fur)
                .frame(width: 96, height: 86)
                .overlay {
                    Ellipse().stroke(Palette.ink.opacity(0.55), lineWidth: 3)
                }
                .overlay {
                    if id.isFluffy {
                        Circle()
                            .fill(p.furLight.opacity(0.55))
                            .frame(width: 86, height: 78)
                    }
                    if id.isTuxedo {
                        Ellipse()
                            .fill(p.belly)
                            .frame(width: 46, height: 40)
                            .offset(y: 16)
                    }
                }

            Group {
                HStack(spacing: 16) {
                    catEye(p, blink: pose.blink, far: pose.turnSign > 0)
                    catEye(p, blink: pose.blink, far: pose.turnSign < 0)
                }
                .offset(x: faceSlide, y: -4)

                catNose(p)
                    .offset(x: faceSlide * 0.6, y: 14)

                catMouth()
                    .stroke(Palette.ink.opacity(0.75), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
                    .frame(width: 22, height: 12)
                    .offset(x: faceSlide * 0.5, y: 26)

                if pose.mouth == .tongue {
                    Capsule()
                        .fill(Color(red: 0.93, green: 0.45, blue: 0.50))
                        .frame(width: 10, height: 12)
                        .offset(x: faceSlide * 0.5, y: 34)
                }

                HStack(spacing: 70) {
                    whiskers(sign: -1)
                    whiskers(sign: 1)
                }
                .offset(y: 16)
            }
            .opacity(faceOpacity)

            if pose.facing > 0.55 {
                Ellipse()
                    .fill(p.furDark.opacity(0.35))
                    .frame(width: 18, height: 28)
                    .offset(x: -pose.turnSign * 32, y: 4)
                    .opacity((pose.facing - 0.55) / 0.45)
            }
        }
    }

    private func ear(_ p: CharacterPalette, inner: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(p.fur)
                .frame(width: 28, height: 34)
            if inner {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(p.innerEar)
                    .frame(width: 16, height: 20)
                    .offset(y: 4)
            }
        }
        .rotationEffect(.degrees(id.isFluffy ? 6 : 0))
    }

    private func catEye(_ p: CharacterPalette, blink: Double, far: Bool) -> some View {
        let opacity = far ? max(0, 1 - pose.facing * 1.7) : max(0.15, 1 - pose.facing * 0.35)
        return ZStack {
            Capsule()
                .fill(.white)
            Circle()
                .fill(p.iris)
                .frame(width: 13, height: 13)
                .offset(x: pose.turnSign * 1.2, y: 1)
            Circle()
                .fill(Palette.ink.opacity(0.85))
                .frame(width: 6, height: 6)
                .offset(x: pose.turnSign * 1.2, y: 1)
            Circle()
                .fill(.white)
                .frame(width: 4.5, height: 4.5)
                .offset(x: 3, y: -3)
        }
        .frame(width: 22, height: 26)
        .scaleEffect(x: 1, y: max(0.08, 1 - blink))
        .opacity(opacity)
    }

    private func catNose(_ p: CharacterPalette) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(p.nose)
            .frame(width: 12, height: 8)
    }

    private func catMouth() -> CatMouth {
        CatMouth(style: pose.mouth)
    }

    private func whiskers(sign: CGFloat) -> some View {
        VStack(spacing: 5) {
            Capsule().frame(width: 22, height: 1.4).rotationEffect(.degrees(-12 * sign))
            Capsule().frame(width: 24, height: 1.4)
            Capsule().frame(width: 20, height: 1.4).rotationEffect(.degrees(12 * sign))
        }
        .foregroundStyle(Palette.ink.opacity(0.45))
        .offset(x: 6 * sign)
    }

    private func bandana(_ p: CharacterPalette) -> some View {
        ZStack {
            Capsule()
                .fill(p.accessory)
                .frame(width: 78, height: 16)
            Triangle()
                .fill(p.accessory)
                .frame(width: 18, height: 16)
                .offset(x: 36, y: 10)
            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { _ in
                    Circle().fill(.white.opacity(0.7)).frame(width: 4, height: 4)
                }
            }
        }
    }

    private func bell(_ p: CharacterPalette) -> some View {
        ZStack {
            Capsule().fill(p.furDark).frame(width: 36, height: 6).offset(y: -10)
            Circle().fill(p.accessory).frame(width: 16, height: 16)
            Capsule().fill(p.furDark.opacity(0.55)).frame(width: 8, height: 3)
        }
    }
}

struct CatMouth: Shape {
    var style: Mouth

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch style {
        case .smile, .tongue:
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.midY),
                control: CGPoint(x: rect.midX, y: rect.maxY)
            )
        case .open:
            path.addEllipse(in: rect.insetBy(dx: 2, dy: 0))
        case .derp:
            path.move(to: CGPoint(x: rect.minX, y: rect.midY - 2))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.midY + 3),
                control: CGPoint(x: rect.midX + 2, y: rect.maxY)
            )
        case .flat:
            path.move(to: CGPoint(x: rect.minX + 2, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX - 2, y: rect.midY))
        }
        return path
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
