//
//  FloatingTabBarView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/15/25.
//

import SwiftUI
import SwiftData

struct FloatingTabBarView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var proManager: ProStatusManager
    @Binding var selectedTab: TabAction

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabAction.allCases, id: \.self) { tab in
                if !(tab == .trends && !proManager.isPro) {
                    Button(action: {
                        Haptic.tap()
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(
                                    .system(
                                        size: 18,
                                        weight: selectedTab == tab ? .semibold : .regular
                                    )
                                )
                            Text(tab.title)
                                .font(.caption2)
                        }
                        .themedForeground(
                            selectedTab == tab ? themeManager.currentTheme.primary : themeManager.currentTheme.primary.opacity(0.5)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(
                    color: colorScheme == .dark ? .white.opacity(0.1)
                    : .black.opacity(0.1),
                    radius: 10,
                    x: 0,
                    y: -2
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.1),
                            lineWidth: 1
                        )
                }
        }
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

        return FloatingTabBarView(
            selectedTab: .constant(.overview)
        )
        .environmentObject(mockThemeManager)
        .environmentObject(achievementManager)
        .environmentObject(freeProManager)
        .environmentObject(mockStoreManager)
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

        return FloatingTabBarView(
            selectedTab: .constant(.overview)
        )
        .environmentObject(mockThemeManager)
        .environmentObject(achievementManager)
        .environmentObject(proManager)
        .environmentObject(mockStoreManager)
    }()
    return view
}
