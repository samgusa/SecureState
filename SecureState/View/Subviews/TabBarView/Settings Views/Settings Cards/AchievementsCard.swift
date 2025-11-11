//
//  AchievementsCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/8/25.
//

import SwiftUI
import SwiftData

struct AchievementsCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var achievementsManager: AchievementsManager
    @State private var achievementSheet: Bool = false
    @Binding var badgeRefreshTrigger: Bool

    var body: some View {
        Button {
            achievementSheet = true
        } label: {
            SettingsRow(
                icon: "crown",
                title: "Achievements",
                subtitle: "Check your Achievements",
                color: themeManager.currentTheme.successColor
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $achievementSheet) {
            badgeRefreshTrigger.toggle()
        } content: {
            AchievementsView(manager: achievementsManager)
        }
    }
}

#Preview("Free User") {
    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()
    let achievementManager = AchievementsManager(modelContext: container.mainContext)
    let mockThemeManager = ThemeManager()
    let mockStoreManager = EnhancedStoreManager()
    let freeProManager = ProStatusManager(storeManager: mockStoreManager)

    AchievementsCard(badgeRefreshTrigger: .constant(false))
        .environmentObject(mockThemeManager)
        .environmentObject(achievementManager)
        .environmentObject(freeProManager)

}

#Preview("Pro User") {

    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()
    let achievementManager = AchievementsManager(modelContext: container.mainContext)
    let mockThemeManager = ThemeManager()
    let mockStoreManager = EnhancedStoreManager()
    let proManager = ProStatusManager(storeManager: mockStoreManager, debug: true)

    AchievementsCard(badgeRefreshTrigger: .constant(false))
        .environmentObject(mockThemeManager)
        .environmentObject(achievementManager)
        .environmentObject(proManager)
}
