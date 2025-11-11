//
//  UnlockedAchievement.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftData

@Model
final class UnlockedAchievement {
    var achievementId: String
    var unlockedDate: Date

    init(achievementId: String, unlockedDate: Date) {
        self.achievementId = achievementId
        self.unlockedDate = unlockedDate
    }
}
