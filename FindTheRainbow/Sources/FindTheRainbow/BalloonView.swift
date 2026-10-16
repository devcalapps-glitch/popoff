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
                if case .target = content {
                    GameHaptics.find()
                } else {
                    GameHaptics.miss()
                }
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
        MysteryBalloon()
            .frame(width: side * 0.88, height: side * 0.88)
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
