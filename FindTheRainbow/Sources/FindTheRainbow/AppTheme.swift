import SwiftUI

enum AppTheme {
    static let balloon = Color(red: 0.92, green: 0.22, blue: 0.38)
    static let balloonDeep = Color(red: 0.72, green: 0.10, blue: 0.28)
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
