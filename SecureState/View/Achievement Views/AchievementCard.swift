//
//  AchievementCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct AchievementCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let achievement: Achievement
    let isSelected: Bool
    let onSelect: () -> Void

    var basicGradient: LinearGradient {
        LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? achievement.rarity.gradient : basicGradient)
                        .frame(width: 70, height: 70)

                    if achievement.isUnlocked {
                        Image(systemName: achievement.icon)
                            .font(.title)
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }

                    if isSelected {
                        Circle()
                            .stroke(themeManager.currentTheme.successColor, lineWidth: 3)
                            .frame(width: 76, height: 76)
                    }
                }

                VStack(spacing: 4) {
                    Text(achievement.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(achievement.isUnlocked ? themeManager.currentTheme.primary : .secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    Text(achievement.rarity.rawValue)
                        .font(.caption2)
                        .foregroundStyle(achievement.rarity.color)

                    if achievement.isUnlocked, let date = achievement.unlockedDate {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .frame(height: 180)
            .cardStyle(achievement.isUnlocked ? achievement.rarity.color : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
#Preview {
    let mockThemeManager = ThemeManager()

    AchievementCard(
        achievement: Achievement(
            achievementID: .firstScan,
            name: "First Steps",
            description: "Complete your first security scan",
            icon: "figure.walk",
            rarity: .common,
            category: .exploration
        ),
        isSelected: false,
        onSelect: { }
    )
    .environmentObject(mockThemeManager)

    AchievementCard(
        achievement: Achievement(
            achievementID: .firstScan,
            name: "First Steps",
            description: "Complete your first security scan",
            icon: "figure.walk",
            rarity: .common,
            category: .exploration
        ),
        isSelected: true,
        onSelect: { }
    )
    .environmentObject(mockThemeManager)
}
