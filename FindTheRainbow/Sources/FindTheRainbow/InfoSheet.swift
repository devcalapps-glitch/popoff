import SwiftUI

enum AppInfo {
    static let displayName = "Pop & Seek"
    static let tagline = "Pop balloons. Find what's hidden."
    static let developerName = "Longest Chariot LLC"
    static let supportEmail = "support@longestchariot.com"

    /// Public pages for App Store Connect / in-app links.
    static let privacyPolicyURL = URL(string: "https://github.com/devcalapps-glitch/popoff/blob/main/PRIVACY.md")
    static let supportURL = URL(string: "https://github.com/devcalapps-glitch/popoff/blob/main/SUPPORT.md")

    static var versionString: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }
}

struct InfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    section(title: "How to play") {
                        numberedTip(1, "Every balloon looks the same until you pop it.")
                        numberedTip(2, "Find every hidden prize for the level — donuts, stars, diamonds, hearts, then crowns.")
                        numberedTip(3, "Finish a level to unlock the next. Later levels hide fewer prizes, so each find matters more.")
                    }
                    section(title: "About") {
                        Text("\(AppInfo.displayName) is a casual search game. Pop identical balloons to uncover hidden prizes across 25 levels.")
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Developed by \(AppInfo.developerName)")
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.textSecondary)
                        Text("Version \(AppInfo.versionString)")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textSecondary.opacity(0.8))
                    }
                    section(title: "Privacy") {
                        Text("\(AppInfo.displayName) works offline on your device. Progress is saved only on this iPhone using local storage. We do not collect, sell, or share personal data, and we do not use tracking or third-party analytics.")
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        if let url = AppInfo.privacyPolicyURL {
                            Link(destination: url) {
                                Label("Full privacy policy", systemImage: "arrow.up.right.square")
                                    .font(AppTheme.captionFont.weight(.semibold))
                                    .foregroundStyle(AppTheme.balloon)
                            }
                        }
                    }
                    section(title: "Support") {
                        Text("Need help with \(AppInfo.displayName)? Reach \(AppInfo.developerName) using the options below.")
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        if let url = AppInfo.supportURL {
                            Link(destination: url) {
                                Label("Support page", systemImage: "arrow.up.right.square")
                                    .font(AppTheme.captionFont.weight(.semibold))
                                    .foregroundStyle(AppTheme.balloon)
                            }
                        }

                        if let mail = URL(string: "mailto:\(AppInfo.supportEmail)") {
                            Link(destination: mail) {
                                Label(AppInfo.supportEmail, systemImage: "envelope")
                                    .font(AppTheme.bodyFont)
                                    .foregroundStyle(AppTheme.balloon)
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 24)
            }
            .background(Color.black.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.balloon)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(AppTheme.panel, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 14) {
            MysteryBalloon()
                .frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 4) {
                Text(AppInfo.displayName)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.textPrimary)
                Text(AppInfo.tagline)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .softPanel()
        }
    }

    private func numberedTip(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(AppTheme.captionFont.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(AppTheme.balloon))
            Text(text)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
