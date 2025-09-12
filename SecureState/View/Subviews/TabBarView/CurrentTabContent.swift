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
    @Binding var selectedComponentForConfirmation: SecurityComponent?
    @Binding var needsAttentionComponents: Set<String>
    let maxDeviceScore: Double
    var devicePercentage: Double
    let maxSituationalScore: Double
    var situationalPercentage: Double
    var scoreColors: [Color]
    let onConfirm: (SecurityComponent, Bool) -> Void
    let networkType: String
    let networkName: String
    let enhancedLocationContextDetector: EnhancedLocationContextDetector
    let realDeviceComponents: [SecurityComponent]
    let realSituationalComponents: [SecurityComponent]

    var body: some View {
        switch selectedTab {
        case .overview:
            if let _ = selectedSection {
                ComponentDetailsView(
                    securitySection: $selectedSection,
                    selectedComponentForConfirmation: $selectedComponentForConfirmation,
                    needsAttentionComponents: $needsAttentionComponents,
                    onConfirm: onConfirm,
                    networkType: networkType,
                    networkName: networkName,
                    enhancedLocationContextDetector: enhancedLocationContextDetector,
                    realDeviceComponents: realDeviceComponents,
                    realSituationalComponents: realSituationalComponents
                )
            } else {
                OverviewView(
                    deviceScore: $deviceScore,
                    maxDeviceScore: maxDeviceScore,
                    devicePercentage: devicePercentage,
                    situationalScore: $situationalScore,
                    maxSituationalScore: maxSituationalScore,
                    situationalPercentage: situationalPercentage,
                    scoreColors: scoreColors,
                    selectedSection: $selectedSection
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
        selectedComponentForConfirmation: .constant(
            SecurityComponent(
                name: "Password Manager",
                score: 10,
                maxScore: 10,
                icon: "key"
            )
        ),
        needsAttentionComponents: .constant([]),
        maxDeviceScore: 55,
        devicePercentage: 0.8,
        maxSituationalScore: 45,
        situationalPercentage: 0.7,
        scoreColors: [.red, .green],
        onConfirm: { a, b in
        },
        networkType: "",
        networkName: "",
        enhancedLocationContextDetector: .init(),
        realDeviceComponents: [
            SecurityComponent(name: "VPN Status", score: 10, maxScore: 20, icon: "shield"),
            SecurityComponent(name: "iOS Version", score: 8, maxScore: 15, icon: "gear"),
            SecurityComponent(name: "Network Type", score: 6, maxScore: 15, icon: "wifi"),
            SecurityComponent(name: "Screen Recording", score: 5, maxScore: 5, icon: "eye.slash")
        ],
        realSituationalComponents: [
            SecurityComponent(name: "Public Wi-Fi", score: 10, maxScore: 20, icon: "wifi.exclamationmark"),
            SecurityComponent(name: "Location Context", score: 8, maxScore: 15, icon: "location"),
            SecurityComponent(name: "Time Risk", score: 5, maxScore: 5, icon: "clock"),
            SecurityComponent(name: "Background Activity", score: 5, maxScore: 5, icon: "app.badge")
        ]
    )
}
