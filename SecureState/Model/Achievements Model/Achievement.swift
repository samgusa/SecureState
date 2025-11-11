//
//  Achievement.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI

// Achievements
struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let achievementID: AchievementID
    let name: String
    let description: String
    let icon: String
    let rarity: Rarity
    let category: Category
    var unlockedDate: Date?

    init(
        achievementID: AchievementID,
        name: String,
        description: String,
        icon: String,
        rarity: Rarity,
        category: Category,
        unlockedDate: Date? = nil
    ) {
        self.id = achievementID.rawValue
        self.achievementID = achievementID
        self.name = name
        self.description = description
        self.icon = icon
        self.rarity = rarity
        self.category = category
        self.unlockedDate = unlockedDate
    }

    enum Rarity: String, Codable {
        case common = "Common"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"

        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            }
        }

        var gradient: LinearGradient {
            switch self {
            case .common:
                return LinearGradient(colors: [.gray, Color.gray.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .rare:
                return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .epic:
                return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .legendary:
                return LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }

    enum Category: String, Codable {
        case security = "Security"
        case exploration = "Exploration"
        case consistency = "Consistency"
        case mastery = "Mastery"

        var icon: String {
            switch self {
            case .security: return "shield.fill"
            case .exploration: return "map.fill"
            case .consistency: return "calendar.badge.clock"
            case .mastery: return "star.fill"
            }
        }
    }

    var isUnlocked: Bool {
        unlockedDate != nil
    }
}
