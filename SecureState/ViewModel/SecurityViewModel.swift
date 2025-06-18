//
//  SecurityViewModel.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import Foundation
import SwiftUI

@MainActor
class SecurityViewModel: ObservableObject {
    @Published var deviceScore: Double = 45 // Out of 45
    @Published var situationalScore: Double = 35 // Out of 35
    @Published var animateScore: Bool = false
    @Published var selectedSection: SecuritySection? = nil
    @Published var showingDetails: Bool = false
    @Published var selectedTab: TabAction = .overview
    @Published var isRefreshing: Bool = false
    @Published var scrollOffset: CGFloat = 0
    @Published var lastRefreshTime = Date()

    let maxDeviceScore: Double = 55
    let maxSituationalScore: Double = 45

    var devicePercentage: Double {
        min(deviceScore / maxDeviceScore, 1.0)
    }

    var situationalPercentage: Double {
        min(situationalScore / maxSituationalScore, 1.0)
    }

    var totalScore: Double {
        deviceScore + situationalScore
    }

    var totalMaxScore: Double {
        maxDeviceScore + maxSituationalScore
    }

    var overallPercentage: Double {
        totalScore / totalMaxScore
    }

    var overallScoreColor: Color {
        scoreColors(for: overallPercentage).first ?? .gray
    }

    // Security status message based on overall score
    var securityStatus: (message: String, color: Color, icon: String) {
        switch overallPercentage {
        case 0.85...1.0:
            return ("Excellent Security", .green, "shield.checkered")
        case 0.70..<0.85:
            return ("Good Protection", .mint, "shield")
        case 0.55..<0.70:
            return ("Moderate Risk", .orange, "shield.slash")
        case 0.40..<0.55:
            return ("High Risk", .red, "exclamationmark.shield")
        default:
            return ("Critical Risk", .red, "xmark.shield")
        }
    }

    // MARK: - Computed Properties

    var situationalGradient: LinearGradient {
        let colors = scoreColors(for: situationalPercentage)
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .center
        )
    }

    var deviceGradient: LinearGradient {
        let colors = scoreColors(for: devicePercentage)
        return LinearGradient(
            colors: colors,
            startPoint: .center,
            endPoint: .bottomTrailing
        )
    }

    func scoreColors(for percentage: Double) -> [Color] {
        switch percentage {
        case 0.8...1.0:
            return [.green, .mint]
        case 0.6..<0.8:
            return [.orange, .yellow]
        default:
            return [.red, .pink]
        }
    }

    // Security advice based on current scores
    func getSecurityAdvice() -> String {
        if devicePercentage < 0.5 {
            return "Focus on device security - enable VPN, password manager, and update iOS"
        } else if situationalPercentage < 0.5 {
            return "Be cautious of your current environment - avoid public Wi-Fi and risky locations"
        } else {
            return "Consider enabling additional security measures for maximum protection"
        }
    }

    // Simulate security refresh
    func performSecurityRefresh() async {
        isRefreshing = true

        // Simulate network check time
        try? await Task.sleep(for: .seconds(1.5))

        // Simulate some score changes (in real app, this would be actual security checks)
        withAnimation(.easeInOut(duration: 0.8)) {
            // Random small variations for demo
            deviceScore = max(20, min(55, deviceScore + Double.random(in: -3...3)))
            situationalScore = max(15, min(45, situationalScore + Double.random(in: -2...2)))
            animateScore.toggle()
        }

        lastRefreshTime = Date()
        isRefreshing = false
    }
}

#Preview {
    ContentView()
}
