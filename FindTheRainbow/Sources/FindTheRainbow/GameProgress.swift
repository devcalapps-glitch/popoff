import SwiftUI

enum RevealTheme: Equatable {
    case donut
    case star
    case diamond
    case heart
    case crown

    var name: String {
        switch self {
        case .donut: return "Donuts"
        case .star: return "Stars"
        case .diamond: return "Diamonds"
        case .heart: return "Hearts"
        case .crown: return "Crowns"
        }
    }

    var symbolName: String {
        switch self {
        case .donut: return "circle.circle.fill"
        case .star: return "star.fill"
        case .diamond: return "diamond.fill"
        case .heart: return "heart.fill"
        case .crown: return "crown.fill"
        }
    }

    var usesCustomIcon: Bool {
        self == .donut
    }

    var isMulticolor: Bool {
        false
    }

    var tintColor: Color {
        switch self {
        case .donut: return Color(red: 1.0, green: 0.55, blue: 0.72)
        case .star: return .yellow
        case .diamond: return .cyan
        case .heart: return .pink
        case .crown: return Color(red: 1, green: 0.78, blue: 0.2)
        }
    }
}

struct ThemeIcon: View {
    let theme: RevealTheme
    var monochrome: Bool = false

    var body: some View {
        Group {
            if theme.usesCustomIcon {
                DonutIcon(monochrome: monochrome)
            } else if theme.isMulticolor {
                Image(systemName: theme.symbolName)
                    .symbolRenderingMode(.multicolor)
            } else {
                Image(systemName: theme.symbolName)
                    .foregroundStyle(theme.tintColor)
            }
        }
    }
}

struct DonutIcon: View {
    var monochrome: Bool = false

    private let dough = Color(red: 0.72, green: 0.45, blue: 0.22)
    private let icing = Color(red: 1.0, green: 0.55, blue: 0.72)
    private let hole = Color.black

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                Circle()
                    .fill(monochrome ? Color.white.opacity(0.85) : dough)
                    .frame(width: side, height: side)
                Circle()
                    .fill(monochrome ? Color.white.opacity(0.55) : icing)
                    .frame(width: side * 0.78, height: side * 0.78)
                if !monochrome {
                    ForEach(0..<6, id: \.self) { index in
                        Capsule()
                            .fill(sprinkleColor(index))
                            .frame(width: side * 0.08, height: side * 0.18)
                            .rotationEffect(.degrees(Double(index) * 60))
                            .offset(y: -side * 0.28)
                            .rotationEffect(.degrees(Double(index) * 60 + 15))
                    }
                }
                Circle()
                    .fill(hole)
                    .frame(width: side * 0.32, height: side * 0.32)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private func sprinkleColor(_ index: Int) -> Color {
        let colors: [Color] = [.yellow, .cyan, .white, .mint, .orange, .purple]
        return colors[index % colors.count]
    }
}

enum GameConstants {
    static let totalLevels = 25
    static let gridColumns = 8
    static let gridRows = 8
    static var totalCells: Int { gridColumns * gridRows }

    private static let themeTiers: [RevealTheme] = [.donut, .star, .diamond, .heart, .crown]
    private static let levelsPerTier = 5

    static func targetCount(forLevel level: Int) -> Int {
        // Level 1 -> 25 targets to find, Level 25 -> just 1.
        totalLevels - level + 1
    }

    static func revealTheme(forLevel level: Int) -> RevealTheme {
        let tierIndex = min((level - 1) / levelsPerTier, themeTiers.count - 1)
        return themeTiers[tierIndex]
    }
}

final class GameProgress: ObservableObject {
    private static let unlockedKey = "highestUnlockedLevel"
    private static let completedKey = "completedLevels"

    @Published private(set) var highestUnlockedLevel: Int
    @Published private(set) var completedLevels: Set<Int>

    init() {
        let defaults = UserDefaults.standard
        let stored = defaults.integer(forKey: Self.unlockedKey)
        highestUnlockedLevel = max(1, stored)
        if let saved = defaults.array(forKey: Self.completedKey) as? [Int] {
            completedLevels = Set(saved)
        } else {
            completedLevels = []
        }
    }

    func isUnlocked(_ level: Int) -> Bool {
        level <= highestUnlockedLevel
    }

    func isCompleted(_ level: Int) -> Bool {
        completedLevels.contains(level)
    }

    func completeLevel(_ level: Int) {
        completedLevels.insert(level)
        if level + 1 > highestUnlockedLevel {
            highestUnlockedLevel = min(GameConstants.totalLevels, level + 1)
        }
        persist()
    }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(highestUnlockedLevel, forKey: Self.unlockedKey)
        defaults.set(Array(completedLevels), forKey: Self.completedKey)
    }
}
