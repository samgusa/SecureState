//
//  AchievementsView.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI
import SwiftData

struct AchievementsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var manager: AchievementsManager
    @EnvironmentObject var proManager: ProStatusManager
    @State private var selectedCategory: Achievement.Category?
    @State private var showLockedOnly: Bool = false

    var filteredAchievements: [Achievement] {
        var filtered = manager.achievements

        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }

        if showLockedOnly {
            filtered = filtered.filter { !$0.isUnlocked }
        }

        return filtered.sorted { first, second in
            if first.isUnlocked != second.isUnlocked {
                return first.isUnlocked
            }
            return first.rarity.rawValue > second.rarity.rawValue
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if !proManager.isPro {
                        proUpgradePrompt
                    } else {
#if DEBUG
                        debugUnlockAllButton
#endif
                        progressSection
                        filtersSection
                        achievementsGrid
                    }
                }
                .padding()
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
        }
        .overlay(alignment: .top) {
            if let achievement = manager.recentlyUnlocked {
                AchievementUnlockedBanner(achievement: achievement)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: manager.recentlyUnlocked)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private var proUpgradePrompt: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, themeManager.currentTheme.warningColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            }

            Text("Achievement System")
                .font(.title2)
                .fontWeight(.bold)

            Text("Earn badges and rewards as you master security concepts")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                FeatureBullet(icon: "medal.fill", text: "15 unique achievements to unlock", color: themeManager.currentTheme.warningColor)
                FeatureBullet(icon: "star.fill", text: "4 rarity tiers from Common to Legendary", color: .yellow)
                FeatureBullet(icon: "sparkles", text: "Display your favorite badge", color: .purple)
            }
            .padding()
            .themedBackground(0.1)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 40)
    }

#if DEBUG
    private var debugUnlockAllButton: some View {
        Button {
            // UNlock all acheivements temporarily for preview
            for achievement in Achievement.allAchievements {
                if !achievement.isUnlocked {
                    manager.unlockAchievement(achievement.id)
                }
            }
        } label: {
            HStack {
                Image(systemName: "hammer.fill")
                Text("DEBUG: Unlock All Achievements")
            }
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.red)
            .clipShape(Capsule())
        }
    }
#endif

    private var progressSection: some View {
        // Overall progress
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Collection Progress")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(themeManager.currentTheme.primary)

                    Text("\(manager.unlockedCount) of \(manager.totalCount) unlocked")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                ZStack {
                    Circle()
                        .stroke(themeManager.currentTheme.primary.opacity(0.2), lineWidth: 8)
                        .frame(width: 60, height: 60)

                    Circle()
                        .trim(from: 0, to: manager.completionPercentage)
                        .stroke(
                            LinearGradient(
                                colors: [themeManager.currentTheme.primary, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(manager.completionPercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }

            // Rarity Breakdown
            HStack(spacing: 12) {
                ForEach([Achievement.Rarity.common, .rare, .epic, .legendary], id: \.self) { rarity in
                    let count = manager.achievements.filter { $0.rarity == rarity && $0.isUnlocked }.count
                    let total = manager.achievements.filter { $0.rarity == rarity }.count

                    VStack(spacing: 4) {
                        Text("\(count)/\(total)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(rarity.color)

                        Text(rarity.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(rarity.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .themedBackground(0.1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var filtersSection: some View {
        VStack(spacing: 12) {
            // Category Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All",
                        icon: nil,
                        isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                    ForEach([Achievement.Category.security, .exploration, .consistency, .mastery], id: \.self) { category in
                        FilterChip(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                    }
                }
            }

            // show locked toggle
            Toggle("Show locked only", isOn: $showLockedOnly)
                .font(.subheadline)
        }
    }

    private var achievementsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(filteredAchievements) { achievement in
                AchievementCard(
                    achievement: achievement,
                    isSelected: manager.selectedBadge?.id == achievement.id,
                    onSelect: {
                        if achievement.isUnlocked {
                            if manager.selectedBadge?.id == achievement.id {
                                manager.clearBadge()
                            } else {
                                manager.selectBadge(achievement)
                            }
                        }
                    }
                )
            }
        }
    }
}

//#Preview {
//    AchievementsView(manager: AchievementsManager())
//}

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

        return AchievementsView(manager: achievementManager)
            .environmentObject(freeProManager)
            .environmentObject(mockThemeManager)
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

        return AchievementsView(manager: achievementManager)
            .environmentObject(proManager)
            .environmentObject(mockThemeManager)
    }()
    return view
}
