//
//  Extensions+Achievement.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation

extension Achievement {
    static let allAchievements: [Achievement] = [
        // COMMON - Getting Started
        Achievement(
            achievementID: .firstScan,
            name: "First Steps",
            description: "Complete your first security scan",
            icon: "figure.walk",
            rarity: .common,
            category: .exploration
        ),
        Achievement(
            achievementID: .perfectScore,
            name: "Fortress",
            description: "Achieve a perfect 100/100 security score",
            icon: "crown.fill",
            rarity: .common,
            category: .security
        ),
        Achievement(
            achievementID: .vpnConfirmed,
            name: "Encrypted Traveler",
            description: "Confirm VPN usage for the first time",
            icon: "lock.shield.fill",
            rarity: .common,
            category: .security
        ),

        // RARE - Consistency & Exploration
        Achievement(
            achievementID: .weekStreak,
            name: "Vigilant Guardian",
            description: "Check your security 7 days in a row",
            icon: "flame.fill",
            rarity: .rare,
            category: .consistency
        ),
        Achievement(
            achievementID: .allComponents,
            name: "Security Scholar",
            description: "View details for all security components",
            icon: "book.fill",
            rarity: .rare,
            category: .exploration
        ),
        Achievement(
            achievementID: .themeCollector,
            name: "Aesthete",
            description: "Try 5 different color themes",
            icon: "paintpalette.fill",
            rarity: .rare,
            category: .exploration
        ),

        // EPIC - Advanced & Challenging
        Achievement(
            achievementID: .monthStreak,
            name: "Unwavering Sentinel",
            description: "Check security for 30 consecutive days",
            icon: "shield.checkered",
            rarity: .epic,
            category: .consistency
        ),
        Achievement(
            achievementID: .perfectWeek,
            name: "Flawless Week",
            description: "Maintain 90+ security score for 7 days",
            icon: "star.circle.fill",
            rarity: .epic,
            category: .mastery
        ),
        Achievement(
            achievementID: .biometricAce,
            name: "Biometric Ace",
            description: "Successfully test biometric auth 10 times",
            icon: "faceid",
            rarity: .epic,
            category: .mastery
        ),
        Achievement(
            achievementID: .trendWatcher,
            name: "Threat Analyst",
            description: "Check security trends 30 times",
            icon: "chart.xyaxis.line",
            rarity: .epic,
            category: .exploration
        ),

        // LEGENDARY - Ultra Rare
        Achievement(
            achievementID: .hundredDays,
            name: "Eternal Protector",
            description: "Check security for 100 consecutive days",
            icon: "infinity.circle.fill",
            rarity: .legendary,
            category: .consistency
        ),
        Achievement(
            achievementID: .perfectMonth,
            name: "Security Grandmaster",
            description: "Maintain 95+ score for 30 consecutive days",
            icon: "medal.fill",
            rarity: .legendary,
            category: .mastery
        ),
        Achievement(
            achievementID: .completionist,
            name: "Completionist",
            description: "Unlock all other achievements",
            icon: "trophy.fill",
            rarity: .legendary,
            category: .mastery
        )
    ]

}
