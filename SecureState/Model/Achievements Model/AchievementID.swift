//
//  AchievementID.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI

enum AchievementID: String, CaseIterable, Hashable, Codable {
    case firstScan = "first_scan"
    case perfectScore = "perfect_score"
    case vpnConfirmed = "vpn_confirmed"
    case weekStreak = "week_streak"
    case allComponents = "all_components"
    case themeCollector = "theme_collector"
    case monthStreak = "month_streak"
    case perfectWeek = "perfect_week"
    case biometricAce = "biometric_ace"
    case trendWatcher = "trend_watcher"
    case hundredDays = "hundred_days"
    case perfectMonth = "perfect_month"
    case completionist = "completionist"
}
