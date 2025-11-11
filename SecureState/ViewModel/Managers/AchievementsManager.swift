//
//  AchievementsManager.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class AchievementsManager: ObservableObject {
    @Published var achievements: [Achievement] = Achievement.allAchievements
    @Published var recentlyUnlocked: Achievement?
    @Published var selectedBadge: Achievement?

    private let modelContext: ModelContext

    // Tracking stats for achievements
    @Published var consecutiveDays: Int = 0
    @Published var perfectScoreDays: Int = 0
    @Published var highScoreDays: Int = 0
    @Published var componentsViewed: Set<String> = []
    @Published var simulatorsUsed: Set<String> = []
    @Published var themesUsed: Set<String> = []
    @Published var biometricTests: Int = 0
    @Published var trendsViews: Int = 0
    @Published var lastCheckDate: Date?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadUnlockedAchievements()
        loadSelectedBadge()
        loadStats()
    }

    private func loadUnlockedAchievements() {
        let descriptor = FetchDescriptor<UnlockedAchievement>()
        guard let unlocked = try? modelContext.fetch(descriptor) else { return }

        for unlockedAch in unlocked {
            if let index = achievements.firstIndex(where: { $0.id == unlockedAch.achievementId }) {
                achievements[index].unlockedDate = unlockedAch.unlockedDate
            }
        }
    }

    private func loadStats() {
        consecutiveDays = UserDefaults.standard.integer(forKey: "consecutiveDays")
        perfectScoreDays = UserDefaults.standard.integer(forKey: "perfectScoreDays")
        highScoreDays = UserDefaults.standard.integer(forKey: "highScoreDays")
        biometricTests = UserDefaults.standard.integer(forKey: "biometricTests")
        trendsViews = UserDefaults.standard.integer(forKey: "trendsViews")

        if let componentsData = UserDefaults.standard.data(forKey: "componentsViewed"),
           let components = try? JSONDecoder().decode(Set<String>.self, from: componentsData) {
            componentsViewed = components
        }

        if let simulatorsData = UserDefaults.standard.data(forKey: "simulatorsUsed"),
           let simulators = try? JSONDecoder().decode(Set<String>.self, from: simulatorsData) {
            simulatorsUsed = simulators
        }

        if let themesData = UserDefaults.standard.data(forKey: "themesUsed"),
           let themes = try? JSONDecoder().decode(Set<String>.self, from: themesData) {
            themesUsed = themes
        }

        if let lastCheck = UserDefaults.standard.object(forKey: "lastCheckDate") as? Date {
            lastCheckDate = lastCheck
        }
    }

    private func loadSelectedBadge() {
        if let badgeId = UserDefaults.standard.string(forKey: "selectedBadge"),
           let badge = achievements.first(where: { $0.id == badgeId && $0.isUnlocked }) {
            selectedBadge = badge
        } else {
            selectedBadge = nil
        }
    }

    private func saveStats() {
        UserDefaults.standard.set(consecutiveDays, forKey: "consecutiveDays")
        UserDefaults.standard.set(perfectScoreDays, forKey: "perfectScoreDays")
        UserDefaults.standard.set(highScoreDays, forKey: "highScoreDays")
        UserDefaults.standard.set(biometricTests, forKey: "biometricTests")
        UserDefaults.standard.set(trendsViews, forKey: "trendsViews")

        if let componentsData = try? JSONEncoder().encode(componentsViewed) {
            UserDefaults.standard.set(componentsData, forKey: "componentsViewed")
        }
        if let simulatorData = try? JSONEncoder().encode(simulatorsUsed) {
            UserDefaults.standard.set(simulatorData, forKey: "simulatorsUsed")
        }

        if let themesData = try? JSONEncoder().encode(themesUsed) {
            UserDefaults.standard.set(themesData, forKey: "themesUsed")
        }

        if let lastCheck = lastCheckDate {
            UserDefaults.standard.set(lastCheck, forKey: "lastCheckDate")
        }
    }

    func unlockAchievement(_ achievementId: String) {
        guard let index = achievements.firstIndex(where: { $0.id == achievementId }),
              !achievements[index].isUnlocked else { return }

        let unlockDate = Date()
        achievements[index].unlockedDate = unlockDate

        // persist to SwiftData
        let unlockedAch = UnlockedAchievement(achievementId: achievementId, unlockedDate: unlockDate)
        modelContext.insert(unlockedAch)
        try? modelContext.save()

        // show notification
        recentlyUnlocked = achievements[index]

        // Haptics feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // auto dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.recentlyUnlocked = nil
        }

        Haptic.success()
        // check for completionist achievement
        checkCompletionist()
    }

    private func checkCompletionist() {
        let unlockedCount = achievements.filter { $0.isUnlocked && $0.id != "completionist" }.count
        let totalCount = achievements.count - 1 // Exclude completionist itself

        if unlockedCount == totalCount {
            unlockAchievement("completionist")
        }
    }

    func trackSecurityCheck(score: Int) {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastCheck = lastCheckDate {
            let lastCheckDay = Calendar.current.startOfDay(for: lastCheck)
            let daysDiff = Calendar.current.dateComponents([.day], from: lastCheckDay, to: today).day ?? 0

            if daysDiff == 1 {
                consecutiveDays += 1
            } else if daysDiff > 1 {
                consecutiveDays = 1
            }
        } else {
            consecutiveDays = 1
        }

        lastCheckDate = Date()

        // 1. Perfect Score Check
        if score == 100 {
            perfectScoreDays += 1
            if achievements.first(where: { $0.id == "perfect_score" })?.isUnlocked == false {
                unlockAchievement("perfect_score")
            }
        }

        if score >= 90 {
            highScoreDays += 1
        } else {
            highScoreDays = 0 // Reset streak
        }

        // 2. First Scan Check
        if consecutiveDays == 1 && achievements.first(where: { $0.id == "first_scan" })?.isUnlocked == false {
            unlockAchievement("first_scan")
        }

        // 3. Week Streak Check
        if consecutiveDays >= 7 && achievements.first(where: { $0.id == "week_streak" })?.isUnlocked == false {
            unlockAchievement("week_streak")
        }

        // 4. Month Streak Check
        if consecutiveDays >= 30 && achievements.first(where: { $0.id == "month_streak" })?.isUnlocked == false {
            unlockAchievement("month_streak")
        }

        // 5. Hundred Days Check
        if consecutiveDays >= 100 && achievements.first(where: { $0.id == "hundred_days" })?.isUnlocked == false {
            unlockAchievement("hundred_days")
        }

        // 6. Perfect Week Check (Quality Streaks)
        if highScoreDays >= 7 && achievements.first(where: { $0.id == "perfect_week" })?.isUnlocked == false {
            unlockAchievement("perfect_week")
        }

        // 7. Perfect Month Check (Quality Streaks)
        if highScoreDays >= 30 && achievements.first(where: { $0.id == "perfect_month" })?.isUnlocked == false {
            unlockAchievement("perfect_month")
        }

        saveStats()
    }

    func trackComponentViewed(_ componentId: String) {
        componentsViewed.insert(componentId)

        if componentsViewed.count >= ComponentIdentifier.allCases.count {
            unlockAchievement("all_components")
        }
        saveStats()
    }

    func trackThemeUsed(_ themeId: String) {
        themesUsed.insert(themeId)

        if themesUsed.count >= 5 {
            unlockAchievement("theme_collector")
        }

        saveStats()
    }

    func trackBiometricTest() {
        biometricTests += 1

        if biometricTests >= 10 {
            unlockAchievement("biometric_ace")
        }

        saveStats()
    }

    func trackTrendsView() {
        trendsViews += 1

        if trendsViews >= 30 {
            unlockAchievement("trend_watcher")
        }

        saveStats()
    }

    func trackVPNConfirmed() {
        if !achievements.first(where: { $0.id == "vpn_confirmed" })!.isUnlocked {
            unlockAchievement("vpn_confirmed")
        }
    }

    func selectBadge(_ achievement: Achievement) {
        guard achievement.isUnlocked else { return }

        withAnimation(.spring()) {
            self.selectedBadge = achievement
        }
        UserDefaults.standard.set(achievement.id, forKey: "selectedBadge")

        objectWillChange.send()
        Haptic.tap()
    }

    func clearBadge() {
        withAnimation(.spring()) {
            self.selectedBadge = nil
        }

        UserDefaults.standard.removeObject(forKey: "selectedBadge")
        objectWillChange.send()

        Haptic.tap()
    }

    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }

    var totalCount: Int {
        achievements.count
    }

    var completionPercentage: Double {
        Double(unlockedCount) / Double(totalCount)
    }
}
