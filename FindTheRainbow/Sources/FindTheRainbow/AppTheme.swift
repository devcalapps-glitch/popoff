import SwiftUI
import UIKit

enum GameHaptics {
    private static let missGenerator = UIImpactFeedbackGenerator(style: .soft)
    private static let findGenerator = UINotificationFeedbackGenerator()

    static func miss() {
        missGenerator.prepare()
        missGenerator.impactOccurred(intensity: 0.55)
    }

    static func find() {
        findGenerator.prepare()
        findGenerator.notificationOccurred(.success)
    }

    static func levelComplete() {
        findGenerator.prepare()
        findGenerator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            findGenerator.notificationOccurred(.success)
        }
    }
}

enum AppTheme {
    /// Glossy round mystery balloon — matches the brand mark (no string/knot).
    static let balloon = Color(red: 0.90, green: 0.18, blue: 0.40)
    static let balloonDeep = Color(red: 0.72, green: 0.08, blue: 0.30)
    static let balloonHighlight = Color(red: 1.0, green: 0.62, blue: 0.72)
    static let ink = Color.black
    static let inkElevated = Color(red: 0.14, green: 0.14, blue: 0.16)
    static let panel = Color(red: 0.16, green: 0.16, blue: 0.18)
    static let mist = Color.white.opacity(0.14)
    static let mistStrong = Color.white.opacity(0.22)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)
    static let success = Color(red: 0.40, green: 0.85, blue: 0.55)
    static let revealBase = Color(red: 0.22, green: 0.22, blue: 0.28)

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.title3, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded).weight(.semibold)
    static let levelNumberFont = Font.system(size: 26, weight: .bold, design: .rounded)
}

struct AtmosphereBackground: View {
    var accent: Color = AppTheme.balloon

    var body: some View {
        Color.black
            .ignoresSafeArea()
    }
}

struct SoftPanel: ViewModifier {
    var cornerRadius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(AppTheme.mistStrong, lineWidth: 1)
                    )
            )
    }
}

extension View {
    func softPanel(cornerRadius: CGFloat = 18) -> some View {
        modifier(SoftPanel(cornerRadius: cornerRadius))
    }
}

/// Round glossy balloon used on the board and home brand mark — no string, no knot.
struct MysteryBalloon: View {
    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                Circle()
                    .fill(AppTheme.balloon.opacity(0.35))
                    .frame(width: side * 1.08, height: side * 1.08)
                    .blur(radius: side * 0.08)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.balloon,
                                AppTheme.balloon,
                                AppTheme.balloonDeep
                            ],
                            center: UnitPoint(x: 0.35, y: 0.32),
                            startRadius: side * 0.05,
                            endRadius: side * 0.7
                        )
                    )
                    .frame(width: side, height: side)
                Circle()
                    .fill(AppTheme.balloonHighlight.opacity(0.85))
                    .frame(width: side * 0.28, height: side * 0.28)
                    .offset(x: -side * 0.18, y: -side * 0.18)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}
