import SwiftUI

@main
struct FindTheRainbowApp: App {
    @StateObject private var progress = GameProgress()

    var body: some Scene {
        WindowGroup {
            LevelSelectView()
                .environmentObject(progress)
                .preferredColorScheme(.dark)
        }
    }
}
