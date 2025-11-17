//
//  HeaderView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI
import SwiftData

struct HeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var proManager: ProStatusManager
    @EnvironmentObject var achievementsManager: AchievementsManager
    let isRefreshing: Bool
    let lastRefreshTime: Date
    let securityStatusIcon: String
    let securityStatusColor: Color
    let securityStatusMessage: String
    let overallPercentage: Double
    let performRefresh: () async -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How Secure are you right now?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .themedForeground(themeManager.currentTheme.primary)

                    HStack {
                        Image(systemName: securityStatusIcon)
                            .foregroundStyle(securityStatusColor)
                            .font(.headline)
                        Text(securityStatusMessage)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(securityStatusColor)
                    }
                }
                Spacer()

                // Refresh Button
                Button(action: {
                    Haptic.tap()
                    Task {
                        await performRefresh()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundStyle(themeManager.currentTheme.infoColor)
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                        .animation(
                            .linear(duration: 1)
                            .repeatCount(isRefreshing ? 10 : 1, autoreverses: false),
                            value: isRefreshing
                        )
                }
                .disabled(isRefreshing)

#if DEBUG
                if proManager.isPro {
                    Button("Test") {
                        if achievementsManager.recentlyUnlocked != nil {
                            achievementsManager.recentlyUnlocked = nil
                        } else {
                            achievementsManager.recentlyUnlocked = Achievement(
                                achievementID: .firstScan,
                                name: "Tester",
                                description: "Debug achievement",
                                icon: "star.fill",
                                rarity: .rare,
                                category: .mastery
                            )
                        }
                    }
                }
#endif
            }

            // Last Refresh Time
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                Text("Last updated: \(lastRefreshTime.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if overallPercentage < 0.6 {
                    Text("Action needed")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(
                            themeManager.currentTheme.dangerColor.contrastingTextColor()
                        )
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.currentTheme.dangerColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding()
        .cardStyle(themeManager.currentTheme.primary)
    }
}

#Preview("Free User") {
    // We wrap setup code in a closure that returns the view.
    let mockThemeManager = ThemeManager()

    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let view: some View = {
        let achievementManager = AchievementsManager(modelContext: container.mainContext)
        let mockStoreManager = EnhancedStoreManager()
        let freeProManager = ProStatusManager(storeManager: mockStoreManager)
        freeProManager.isPro = false  // not pro

        return VStack {
            HeaderView(
                isRefreshing: false,
                lastRefreshTime: Date.now,
                securityStatusIcon: "shield",
                securityStatusColor: .green,
                securityStatusMessage: "Secure",
                overallPercentage: 0.7,
                performRefresh: { }
            )
            .padding(.bottom, 50)
            .environmentObject(freeProManager)
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)

            HeaderView(
                isRefreshing: false,
                lastRefreshTime: Date.now,
                securityStatusIcon: "shield",
                securityStatusColor: .green,
                securityStatusMessage: "Secure",
                overallPercentage: 0.5,
                performRefresh: { }
            )
            .environmentObject(freeProManager)
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
        }
    }()
    return view
}

#Preview("Pro User") {
    let mockThemeManager = ThemeManager()

    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let view: some View = {
        let achievementManager = AchievementsManager(modelContext: container.mainContext)
        let mockStoreManager = EnhancedStoreManager()
        let proManager = ProStatusManager(storeManager: mockStoreManager, debug: true)

        return VStack {
            HeaderView(
                isRefreshing: false,
                lastRefreshTime: Date.now,
                securityStatusIcon: "shield",
                securityStatusColor: .green,
                securityStatusMessage: "Secure",
                overallPercentage: 0.7,
                performRefresh: { }
            )
            .padding(.bottom, 50)
            .environmentObject(proManager)
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)

            HeaderView(
                isRefreshing: false,
                lastRefreshTime: Date.now,
                securityStatusIcon: "shield",
                securityStatusColor: .green,
                securityStatusMessage: "Secure",
                overallPercentage: 0.5,
                performRefresh: { }
            )
            .environmentObject(proManager)
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
        }
    }()
    return view
}
