import SwiftUI

struct LevelView: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss
    @State private var level: Int
    @State private var cells: [GridCell]
    @State private var poppedIDs: Set<Int> = []
    @State private var foundCount = 0
    @State private var tries = 0
    @State private var showCompletion = false

    private var findTarget: Int {
        GameConstants.targetCount(forLevel: level)
    }

    private var theme: RevealTheme {
        GameConstants.revealTheme(forLevel: level)
    }

    init(level: Int) {
        _level = State(initialValue: level)
        _cells = State(initialValue: GridLayout.makeCells(forLevel: level))
    }

    var body: some View {
        VStack(spacing: 14) {
            hud
            board
        }
        .padding(.bottom, 8)
        .background(AtmosphereBackground(accent: theme.tintColor))
        .navigationTitle("Level \(level)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .overlay {
            if showCompletion {
                CompletionOverlay(
                    level: level,
                    tries: tries,
                    theme: theme,
                    isLastLevel: level == GameConstants.totalLevels,
                    onNext: goToNextLevel,
                    onDone: { dismiss() }
                )
            }
        }
    }

    private var hud: some View {
        HStack(spacing: 10) {
            hudChip(title: "Taps", value: "\(tries)") {
                Image(systemName: "hand.tap.fill")
                    .foregroundStyle(AppTheme.textSecondary)
            }
            hudChip(title: theme.name, value: "\(foundCount)/\(findTarget)") {
                ThemeIcon(theme: theme)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func hudChip<Icon: View>(
        title: String,
        value: String,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        HStack(spacing: 10) {
            icon()
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 28, height: 28)
                .background(Circle().fill(AppTheme.mist))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(value)
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .softPanel(cornerRadius: 16)
        .frame(maxWidth: .infinity)
    }

    private var board: some View {
        GeometryReader { geo in
            let columnCount = GameConstants.gridColumns
            let rowCount = GameConstants.gridRows
            let spacing: CGFloat = 4
            let inset: CGFloat = 10
            let availableWidth = geo.size.width - inset * 2
            let availableHeight = geo.size.height - inset * 2
            let cellWidth = (availableWidth - spacing * CGFloat(columnCount - 1)) / CGFloat(columnCount)
            let cellHeight = (availableHeight - spacing * CGFloat(rowCount - 1)) / CGFloat(rowCount)
            let columns = Array(repeating: GridItem(.fixed(cellWidth), spacing: spacing), count: columnCount)

            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(cells) { cell in
                    BalloonCellView(
                        content: cell.content,
                        isPopped: poppedIDs.contains(cell.id),
                        theme: theme
                    ) {
                        pop(cell)
                    }
                    .frame(width: cellWidth, height: cellHeight)
                }
            }
            .padding(inset)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppTheme.panel.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(AppTheme.mistStrong, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 12)
    }

    private func pop(_ cell: GridCell) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
            poppedIDs.insert(cell.id)
        }
        tries += 1
        if case .target = cell.content {
            foundCount += 1
            if foundCount == findTarget {
                progress.completeLevel(level)
                GameHaptics.levelComplete()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        showCompletion = true
                    }
                }
            }
        }
    }

    private func goToNextLevel() {
        let next = level + 1
        guard next <= GameConstants.totalLevels else { return }
        level = next
        cells = GridLayout.makeCells(forLevel: next)
        poppedIDs = []
        foundCount = 0
        tries = 0
        showCompletion = false
    }
}

private struct CompletionOverlay: View {
    let level: Int
    let tries: Int
    let theme: RevealTheme
    let isLastLevel: Bool
    let onNext: () -> Void
    let onDone: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(theme.tintColor.opacity(0.18))
                        .frame(width: 72, height: 72)
                    ThemeIcon(theme: theme)
                        .frame(width: 34, height: 34)
                        .font(.system(size: 30, weight: .bold))
                }

                VStack(spacing: 6) {
                    Text(isLastLevel ? "You cleared every level!" : "Level \(level) complete")
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    Text(
                        isLastLevel
                            ? "Every \(theme.name.lowercased()) found."
                            : "All \(theme.name.lowercased()) found in \(tries) taps."
                    )
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                }

                Button {
                    if isLastLevel {
                        onDone()
                    } else {
                        onNext()
                    }
                } label: {
                    Text(isLastLevel ? "Back to Levels" : "Next Level")
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.balloon, AppTheme.balloonDeep],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                if !isLastLevel {
                    Button("Levels", action: onDone)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .padding(28)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppTheme.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(AppTheme.mistStrong, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 30, y: 16)
            )
            .padding(32)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }
}
