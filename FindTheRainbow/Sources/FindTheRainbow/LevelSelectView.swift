import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject private var progress: GameProgress
    @State private var showInfo = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 4)

    private var completedCount: Int {
        progress.completedLevels.count
    }

    private var progressFraction: Double {
        Double(completedCount) / Double(GameConstants.totalLevels)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    progressCard
                    levelGrid
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(AtmosphereBackground())
            .scrollContentBackground(.hidden)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .accessibilityLabel("Info")
                }
            }
            .sheet(isPresented: $showInfo) {
                InfoSheet()
            }
            .navigationDestination(for: Int.self) { destLevel in
                LevelView(level: destLevel)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                brandMark
                VStack(alignment: .leading, spacing: 2) {
                    Text(AppInfo.displayName)
                        .font(AppTheme.titleFont)
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(AppInfo.tagline)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var brandMark: some View {
        MysteryBalloon()
            .frame(width: 56, height: 56)
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your progress")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
                    .textCase(.uppercase)
                Spacer()
                Text("\(completedCount)/\(GameConstants.totalLevels)")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textPrimary)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.mist)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.balloon, AppTheme.balloon.opacity(0.75)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * progressFraction))
                }
            }
            .frame(height: 8)

            Text(progressBlurb)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(16)
        .softPanel()
    }

    private var progressBlurb: String {
        if completedCount == 0 {
            return "Start with Level 1 — every balloon looks the same until you pop it."
        }
        if completedCount == GameConstants.totalLevels {
            return "Every level cleared. Master of the pop."
        }
        return "Level \(progress.highestUnlockedLevel) unlocked. Keep going."
    }

    private var levelGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Levels")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(1...GameConstants.totalLevels, id: \.self) { level in
                    levelCell(level)
                }
            }
        }
    }

    @ViewBuilder
    private func levelCell(_ level: Int) -> some View {
        let unlocked = progress.isUnlocked(level)
        let completed = progress.isCompleted(level)
        let theme = GameConstants.revealTheme(forLevel: level)

        if unlocked {
            NavigationLink(value: level) {
                cellContent(level: level, unlocked: true, completed: completed, theme: theme)
            }
            .buttonStyle(.plain)
        } else {
            cellContent(level: level, unlocked: false, completed: false, theme: theme)
        }
    }

    private func cellContent(level: Int, unlocked: Bool, completed: Bool, theme: RevealTheme) -> some View {
        let accent = completed ? AppTheme.success : theme.tintColor

        return VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        unlocked
                            ? LinearGradient(
                                colors: [
                                    AppTheme.inkElevated.opacity(1),
                                    AppTheme.panel.opacity(0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                unlocked
                                    ? accent.opacity(completed ? 0.8 : 0.55)
                                    : Color.white.opacity(0.18),
                                lineWidth: unlocked ? 1.5 : 1
                            )
                    )

                if unlocked {
                    VStack(spacing: 6) {
                        Text("\(level)")
                            .font(AppTheme.levelNumberFont)
                            .foregroundStyle(AppTheme.textPrimary)
                        if completed {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppTheme.success)
                        } else {
                            ThemeIcon(theme: theme)
                                .frame(width: 18, height: 18)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                } else {
                    VStack(spacing: 6) {
                        Text("\(level)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.35))
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                }
            }
            .frame(height: 92)
            .shadow(
                color: unlocked ? accent.opacity(0.35) : .clear,
                radius: 10,
                y: 4
            )
        }
        .accessibilityLabel(levelAccessibilityLabel(level: level, unlocked: unlocked, completed: completed))
    }

    private func levelAccessibilityLabel(level: Int, unlocked: Bool, completed: Bool) -> String {
        if !unlocked { return "Level \(level), locked" }
        if completed { return "Level \(level), completed" }
        return "Level \(level)"
    }
}
