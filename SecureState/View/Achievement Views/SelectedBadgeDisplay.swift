//
//  SelectedBadgeDisplay.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct SelectedBadgeDisplay: View {
    let achievement: Achievement

    var body: some View {
        ZStack {
            Circle()
                .fill(achievement.rarity.gradient)
                .frame(width: 32, height: 32)

            Image(systemName: achievement.icon)
                .font(.title3)
                .foregroundStyle(.white)
        }
        .shadow(color: achievement.rarity.color.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    SelectedBadgeDisplay(
        achievement: Achievement(
            achievementID: .firstScan,
            name: "First Steps",
            description: "Complete your first security scan",
            icon: "figure.walk",
            rarity: .common,
            category: .exploration
        )
    )
}
