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
    @Published var notificationQueue: [Achievement] = []
    private var activeNotificationId: UUID?

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
    @Published var lastBiometricTest: Date?

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
            if let index = achievements.firstIndex(where: {
                $0.achievementID.rawValue == unlockedAch.achievementId
            }) {
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
        guard !achievements.isEmpty else {
            print("⚠️ Attempted to load badge before achievements loaded")
            return
        }

        if let badgeId = UserDefaults.standard.string(forKey: "selectedBadge"),
           let badge = achievements.first(where: {
               $0.achievementID.rawValue == badgeId && $0.isUnlocked
           }) {
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

    func unlockAchievement(_ achievementId: AchievementID) {
        guard let index = achievements.firstIndex(where: { $0.achievementID == achievementId }),
              !achievements[index].isUnlocked else { return }

        let unlockDate = Date()
        achievements[index].unlockedDate = unlockDate

        // persist to SwiftData
        let unlockedAch = UnlockedAchievement(
            achievementId: achievementId.rawValue,
            unlockedDate: unlockDate
        )
        modelContext.insert(unlockedAch)
        try? modelContext.save()

        // Haptics feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        Haptic.success()

        // Add to notification queue (don't show immediately)
        notificationQueue.append(achievements[index])
        showNextNotification()

        // check for completionist achievement
        checkCompletionist()
    }

    private func showNextNotification() {
        guard recentlyUnlocked == nil, !notificationQueue.isEmpty else { return }

        recentlyUnlocked = notificationQueue.removeFirst()
        let notificationId = UUID()
        activeNotificationId = notificationId

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            if self.activeNotificationId == notificationId {
                self.recentlyUnlocked = nil
                self.showNextNotification()
            }
        }
    }

    private func checkCompletionist() {
        // Early exit if already unlocked
        guard achievements.first(where: { $0.achievementID == .completionist })?.isUnlocked == false else {
            return
        }
        
        let unlockedCount = achievements.filter { $0.isUnlocked && $0.achievementID != .completionist }.count
        let totalCount = achievements.count - 1
        
        if unlockedCount == totalCount {
            unlockAchievement(.completionist)
        }
    }

    func trackSecurityCheck(score: Int) {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastCheck = lastCheckDate {
            let lastCheckDay = Calendar.current.startOfDay(for: lastCheck)
            let daysDiff = Calendar.current.dateComponents([.day], from: lastCheckDay, to: today).day ?? 0

            if daysDiff == 1 {
                consecutiveDays += 1
            } else if daysDiff == 0 {

            } else {
                consecutiveDays = 1
            }
        } else {
            consecutiveDays = 1
        }

        lastCheckDate = Date()

        // 1. Perfect Score Check
        if score == 100 {
            perfectScoreDays += 1
            if !isUnlocked(.perfectScore) {
                unlockAchievement(.perfectScore)
            }
        } else {
            perfectScoreDays = 0
        }

        if score >= 90 {
            highScoreDays += 1
        } else {
            highScoreDays = 0 // Reset streak
        }

        // 2. First Scan Check
        if consecutiveDays == 1 && !isUnlocked(.firstScan) {
            unlockAchievement(.firstScan)
        }

        // 3. Week Streak Check
        if consecutiveDays >= 7 && !isUnlocked(.weekStreak) {
            unlockAchievement(.weekStreak)
        }

        // 4. Month Streak Check
        if consecutiveDays >= 30 && !isUnlocked(.monthStreak) {
            unlockAchievement(.monthStreak)
        }

        // 5. Hundred Days Check
        if consecutiveDays >= 100 && !isUnlocked(.hundredDays) {
            unlockAchievement(.hundredDays)
        }

        // 6. Perfect Week Check (Quality Streaks)
        if highScoreDays >= 7 && !isUnlocked(.perfectWeek) {
            unlockAchievement(.perfectWeek)
        }

        // 7. Perfect Month Check (Quality Streaks)
        if highScoreDays >= 30 && !isUnlocked(.perfectMonth) {
            unlockAchievement(.perfectMonth)
        }

        saveStats()
    }

    func trackComponentViewed(_ componentId: String) {
        componentsViewed.insert(componentId)

        if componentsViewed.count >= ComponentIdentifier.allCases.count {
            unlockAchievement(.allComponents)
        }
        saveStats()
    }

    func trackThemeUsed(_ themeId: String) {
        themesUsed.insert(themeId)

        if themesUsed.count >= 5 {
            unlockAchievement(.themeCollector)
        }

        saveStats()
    }

    func trackBiometricTest() {
        let now = Date()

        // Only count if at least 5 min since last test
        if let last = lastBiometricTest, now.timeIntervalSince(last) < 300 {
            return
        }
        biometricTests += 1

        if biometricTests >= 10 {
            unlockAchievement(.biometricAce)
        }

        saveStats()
    }

    func trackTrendsView() {
        trendsViews += 1

        if trendsViews >= 30 {
            unlockAchievement(.trendWatcher)
        }

        saveStats()
    }

    func trackVPNConfirmed() {
        if !isUnlocked(.vpnConfirmed) {
            unlockAchievement(.vpnConfirmed)
        }
    }

    func selectBadge(_ achievement: Achievement) {
        guard achievement.isUnlocked else { return }

        withAnimation(.spring()) {
            self.selectedBadge = achievement
        }
        UserDefaults.standard.set(achievement.achievementID.rawValue, forKey: "selectedBadge")

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

    func isUnlocked(_ achievementID: AchievementID) -> Bool {
        achievements.first(where: { $0.achievementID == achievementID })?.isUnlocked ?? false
    }
}
