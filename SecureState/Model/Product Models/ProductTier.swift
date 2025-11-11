//
//  ProductTier.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI

enum ProductTier: String, CaseIterable {
    case oneTimePro = "com.securestate.pro"
    case monthlyTrendsPlus = "com.securestate.trendsplus.monthly"
    case yearlyTrendsPlus = "com.securestate.trendsplus.yearly"

    var displayName: String {
        switch self {
        case .oneTimePro:
            return "SecureState Pro"
        case .monthlyTrendsPlus:
            return "Trends Plus (Monthly)"
        case .yearlyTrendsPlus:
            return "Trends Plus (Yearly)"
        }
    }

    var description: String {
        switch self {
        case .oneTimePro:
            return "Unlock themes & achievements forever - one-time purchase"
        case .monthlyTrendsPlus:
            return "Get themes, achievements & global trends - billed monthly"
        case .yearlyTrendsPlus:
            return "Get themes, achievements & global trends - billed yearly"
        }
    }

    var features: [String] {
        switch self {
        case .oneTimePro:
            return [
                "10 Custom Color Themes",
                "15 Achievements System",
                "Badge Display",
                "One-time purchase, yours forever"
            ]
        case .monthlyTrendsPlus:
            return [
                "Everything in Pro",
                "Global Security Trends",
                "Real-time CVE Tracking",
                "90-Day Trend History",
                "Billed monthly"
            ]
        case .yearlyTrendsPlus:
            return [
                "Everything in Pro",
                "Global Security Trends",
                "Real-time CVE Tracking",
                "90-Day Trend History",
                "Save 20% vs monthly"
            ]
        }
    }

    var icon: String {
        switch self {
        case .oneTimePro:
            return "star.fill"
        case .monthlyTrendsPlus, .yearlyTrendsPlus:
            return "chart.line.uptrend.xyaxis"
        }
    }

    var color: Color {
        switch self {
        case .oneTimePro:
            return .orange
        case .monthlyTrendsPlus, .yearlyTrendsPlus:
            return .blue
        }
    }
}
