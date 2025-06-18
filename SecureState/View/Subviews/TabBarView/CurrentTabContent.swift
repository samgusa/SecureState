//
//  CurrentTabContent.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/16/25.
//

import SwiftUI

struct CurrentTabContent: View {
    @Binding var selectedSection: SecuritySection?
    @Binding var deviceScore: Double
    @Binding var situationalScore: Double
    @Binding var selectedTab: TabAction
    let maxDeviceScore: Double
    var devicePercentage: Double
    let maxSituationalScore: Double
    var situationalPercentage: Double
    var scoreColors: [Color]

    var body: some View {
        switch selectedTab {
        case .overview:
            if let selectedSection = selectedSection {
                ComponentDetailsView(
                    securitySection: selectedSection,
                    selectedSection: $selectedSection
                )
            } else {
                OverviewView(
                    deviceScore: $deviceScore,
                    maxDeviceScore: maxDeviceScore,
                    devicePercentage: devicePercentage,
                    situationalScore: $situationalScore,
                    maxSituationalScore: maxSituationalScore,
                    situationalPercentage: situationalPercentage,
                    scoreColors: scoreColors
                )
            }
        case .actions:
            ActionsView(
                devicePercentage: devicePercentage,
                situationalPercentage: situationalPercentage
            )
        case .settings:
            SettingsTabView()
        }
    }
}

#Preview {
    CurrentTabContent(
        selectedSection: .constant(nil),
        deviceScore: .constant(35),
        situationalScore: .constant(28),
        selectedTab: .constant(.overview),
        maxDeviceScore: 55,
        devicePercentage: 0.8,
        maxSituationalScore: 45,
        situationalPercentage: 0.7,
        scoreColors: [.red, .green]
    )
}
