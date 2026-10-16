import SwiftUI

enum CellContent {
    case plain(Color)
    case target
}

struct GridCell: Identifiable {
    let id: Int
    let row: Int
    let col: Int
    let content: CellContent
}

enum GridLayout {
    private static let plainPalette: [Color] = [
        .red, .orange, .yellow, .green, .blue, .indigo, .purple, .pink, .mint, .cyan
    ]

    /// Grid of balloons; `targetCount` of them hide the level's find items,
    /// the rest are plain decoys. Freshly randomized on every call.
    static func makeCells(forLevel level: Int) -> [GridCell] {
        let columns = GameConstants.gridColumns
        let totalCells = GameConstants.totalCells
        let targetCount = GameConstants.targetCount(forLevel: level)

        var indices = Array(0..<totalCells)
        indices.shuffle()
        let targetIndices = Set(indices.prefix(targetCount))

        return (0..<totalCells).map { index in
            let row = index / columns
            let col = index % columns
            let content: CellContent = targetIndices.contains(index)
                ? .target
                : .plain(plainPalette.randomElement() ?? .blue)
            return GridCell(id: index, row: row, col: col, content: content)
        }
    }
}
