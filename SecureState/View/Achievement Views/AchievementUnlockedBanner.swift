//
//  AchievementUnlockedBanner.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct AchievementUnlockedBanner: View {
    @EnvironmentObject var proManager: ProStatusManager
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.rarity.gradient)
                    .frame(width: 50, height: 50)

                Image(systemName: achievement.icon)
                    .foregroundStyle(.white)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked!")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text(achievement.name)
                    .font(.subheadline)
                    .fontWeight(.bold)

                Text(achievement.rarity.rawValue)
                    .font(.caption2)
                    .foregroundStyle(achievement.rarity.color)
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding()
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(10)
    }
}


#Preview("Free User") {
    // We wrap setup code in a closure that returns the view.
    let view: some View = {
        let mockStoreManager = EnhancedStoreManager()
        let freeProManager = ProStatusManager(storeManager: mockStoreManager)
        freeProManager.isPro = false  // not pro

        return AchievementUnlockedBanner(
            achievement: Achievement(
                achievementID: .firstScan,
                name: "First Steps",
                description: "Complete your first security scan",
                icon: "figure.walk",
                rarity: .common,
                category: .exploration
            )
        )
            .environmentObject(freeProManager)
    }()
    return view
}

#Preview("Pro User") {
    let view: some View = {
        let mockStoreManager = EnhancedStoreManager()
        let proManager = ProStatusManager(storeManager: mockStoreManager, debug: true)

        return AchievementUnlockedBanner(
            achievement: Achievement(
                achievementID: .firstScan,
                name: "First Steps",
                description: "Complete your first security scan",
                icon: "figure.walk",
                rarity: .common,
                category: .exploration
            )
        )
            .environmentObject(proManager)
    }()
    return view
}

