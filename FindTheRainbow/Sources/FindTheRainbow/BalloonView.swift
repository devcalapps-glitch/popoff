import SwiftUI
import UIKit

struct BalloonCellView: View {
    let content: CellContent
    let isPopped: Bool
    let theme: RevealTheme
    let onPop: () -> Void

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)

            ZStack {
                if isPopped {
                    revealedView(side: side)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.7).combined(with: .opacity),
                            removal: .opacity
                        ))
                } else {
                    balloonShape(side: side)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .onTapGesture {
                guard !isPopped else { return }
                let isFind = {
                    if case .target = content { return true }
                    return false
                }()
                UIImpactFeedbackGenerator(style: isFind ? .medium : .light).impactOccurred()
                onPop()
            }
        }
        .accessibilityLabel(isPopped ? revealedAccessibilityLabel : "Balloon")
        .accessibilityAddTraits(isPopped ? [] : .isButton)
    }

    private var revealedAccessibilityLabel: String {
        switch content {
        case .plain:
            return "Empty"
        case .target:
            return theme.name
        }
    }

    @ViewBuilder
    private func balloonShape(side: CGFloat) -> some View {
        VStack(spacing: 0) {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.balloon, AppTheme.balloonDeep],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: side * 0.8, height: side * 0.92)
                .overlay(
                    Ellipse()
                        .fill(.white.opacity(0.38))
                        .frame(width: side * 0.22, height: side * 0.3)
                        .offset(x: -side * 0.18, y: -side * 0.22)
                )
                .shadow(color: AppTheme.balloon.opacity(0.35), radius: 3, y: 1)
            Triangle()
                .fill(AppTheme.balloonDeep)
                .frame(width: side * 0.1, height: side * 0.08)
            Capsule()
                .fill(Color.white.opacity(0.28))
                .frame(width: 1.5, height: side * 0.12)
        }
    }

    @ViewBuilder
    private func revealedView(side: CGFloat) -> some View {
        switch content {
        case .plain(let color):
            RoundedRectangle(cornerRadius: side * 0.18, style: .continuous)
                .fill(color.opacity(0.22))
                .overlay(
                    RoundedRectangle(cornerRadius: side * 0.18, style: .continuous)
                        .stroke(color.opacity(0.75), lineWidth: 1.5)
                )
                .frame(width: side * 0.95, height: side * 0.95)
                .overlay(
                    Image(systemName: "wind")
                        .font(.system(size: side * 0.36, weight: .bold))
                        .foregroundStyle(color.opacity(0.9))
                )
        case .target:
            RoundedRectangle(cornerRadius: side * 0.18, style: .continuous)
                .fill(AppTheme.revealBase)
                .overlay(
                    RoundedRectangle(cornerRadius: side * 0.18, style: .continuous)
                        .stroke(theme.tintColor.opacity(0.45), lineWidth: 1.5)
                )
                .frame(width: side * 0.95, height: side * 0.95)
                .overlay(
                    ThemeIcon(theme: theme)
                        .padding(side * 0.16)
                )
                .shadow(color: theme.tintColor.opacity(0.25), radius: 6, y: 2)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
