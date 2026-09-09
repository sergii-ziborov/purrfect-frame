import SwiftUI

enum Palette {
    static let cream = Color(red: 0.965, green: 0.929, blue: 0.890)
    static let creamDark = Color(red: 0.93, green: 0.88, blue: 0.82)
    static let ink = Color(red: 0.145, green: 0.106, blue: 0.086)
    static let inkSoft = Color(red: 0.29, green: 0.22, blue: 0.18)
    static let wood = Color(red: 0.545, green: 0.369, blue: 0.235)
    static let moss = Color(red: 0.18, green: 0.62, blue: 0.42)
    static let mossPressed = Color(red: 0.13, green: 0.50, blue: 0.34)
    static let sky = Color(red: 0.27, green: 0.55, blue: 0.93)
    static let skyPressed = Color(red: 0.20, green: 0.43, blue: 0.78)
    static let gold = Color(red: 0.95, green: 0.74, blue: 0.22)
    static let coral = Color(red: 0.91, green: 0.45, blue: 0.38)
    static let cameraChrome = Color(red: 0.09, green: 0.07, blue: 0.06)
}

extension Font {
    static func pfDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func pfBody(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func pfScript(_ size: CGFloat) -> Font {
        .system(size: size, design: .serif).italic()
    }
}

struct PFButton: View {
    enum Kind { case play, success, quiet, danger }

    var title: String
    var kind: Kind = .play
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.pfBody(18))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(background, in: Capsule())
            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var background: Color {
        switch kind {
        case .play: Palette.sky
        case .success: Palette.moss
        case .quiet: Color.white.opacity(0.92)
        case .danger: Palette.coral
        }
    }

    private var foreground: Color {
        switch kind {
        case .quiet: Palette.ink
        default: .white
        }
    }
}

struct FeaturePill: View {
    var icon: String
    var title: String
    var subtitle: String
    var tint: Color
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 4 : 6) {
            ZStack {
                Circle().fill(tint.opacity(0.18)).frame(width: compact ? 42 : 52, height: compact ? 42 : 52)
                Image(systemName: icon)
                    .font(.system(size: compact ? 16 : 20, weight: .semibold))
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(.pfBody(12))
                .foregroundStyle(Palette.ink)
            Text(subtitle)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Palette.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PFNavBar: View {
    var title: String
    var onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .accessibilityIdentifier("back-button")
            .accessibilityLabel("Back")
            Spacer()
            Text(title)
                .font(.pfDisplay(22))
                .foregroundStyle(Palette.ink)
            Spacer()
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }
}

struct PFScreen<Content: View>: View {
    var title: String
    var onBack: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            PFNavBar(title: title, onBack: onBack)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Palette.cream.ignoresSafeArea())
    }
}

struct SceneCrop: View {
    var name: String
    var height: CGFloat
    var alignment: Alignment = .bottom

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: alignment)
            .clipped()
    }
}

struct StarRow: View {
    var stars: Int
    var size: CGFloat = 22

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.system(size: size, weight: .bold))
                    .foregroundStyle(index < stars ? Palette.gold : Palette.ink.opacity(0.18))
            }
        }
        .accessibilityLabel("\(stars) of 3 stars")
    }
}

struct ViewfinderCorners: View {
    var active: Bool

    var body: some View {
        GeometryReader { geo in
            let color = active ? Palette.moss : Color.white.opacity(0.92)
            CornerBracket()
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 34, height: 34)
                .position(x: 28, y: 28)
            CornerBracket()
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 34, height: 34)
                .rotationEffect(.degrees(90))
                .position(x: geo.size.width - 28, y: 28)
            CornerBracket()
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 34, height: 34)
                .rotationEffect(.degrees(270))
                .position(x: 28, y: geo.size.height - 28)
            CornerBracket()
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 34, height: 34)
                .rotationEffect(.degrees(180))
                .position(x: geo.size.width - 28, y: geo.size.height - 28)
        }
        .allowsHitTesting(false)
    }
}

private struct CornerBracket: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY * 0.62))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX * 0.62, y: rect.minY))
        return path
    }
}
