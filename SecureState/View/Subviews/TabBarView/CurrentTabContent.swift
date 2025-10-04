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
    @Binding var needsAttentionComponents: Set<ComponentIdentifier>
    let maxDeviceScore: Double
    var devicePercentage: Double
    let maxSituationalScore: Double
    var situationalPercentage: Double
    var scoreColors: [Color]
    let onConfirm: (SecurityComponent, Bool) -> Void
    let networkName: String
    let deviceLockDetector: DeviceLockSecurityDetector
    let bluetoothSecurityDetector: EnhancedBluetoothSecurityDetector
    let environmentalSecurityDetector: EnvironmentalSecurityDetector
    let vpnDetector: VPNStatusDetector
    let screenRecordingDetector: ScreenRecordingDetector
    let iosVersionDetector: iOSVersionDetector
    let timeBasedDetector: TimeBasedRiskDetector
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
                    networkName: networkName,
                    deviceLockDetector: deviceLockDetector,
                    bluetoothSecurityDetector: bluetoothSecurityDetector,
                    environmentalSecurityDetector: environmentalSecurityDetector,
                    vpnDetector: vpnDetector,
                    screenRecordingDetector: screenRecordingDetector,
                    iosVersionDetector: iosVersionDetector,
                    timeBasedDetector: timeBasedDetector,
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
                identifier: .vpnStatus,
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
        networkName: "",
        deviceLockDetector: DeviceLockSecurityDetector(),
        bluetoothSecurityDetector: EnhancedBluetoothSecurityDetector(),
        environmentalSecurityDetector: EnvironmentalSecurityDetector(),
        vpnDetector: VPNStatusDetector(),
        screenRecordingDetector: ScreenRecordingDetector(),
        iosVersionDetector: iOSVersionDetector(),
        timeBasedDetector: TimeBasedRiskDetector(),
        realDeviceComponents: [
            SecurityComponent(identifier: .vpnStatus, score: 10, maxScore: 20, icon: "shield"),
            SecurityComponent(identifier: .iosVersion, score: 8, maxScore: 15, icon: "gear"),
            SecurityComponent(identifier: .environmentalSecurity, score: 6, maxScore: 15, icon: "wifi"),
            SecurityComponent(identifier: .screenRecording, score: 5, maxScore: 5, icon: "eye.slash")
        ],
        realSituationalComponents: [
            SecurityComponent(identifier: .deviceLock, score: 10, maxScore: 20, icon: "wifi.exclamationmark"),
            SecurityComponent(identifier: .environmentalSecurity, score: 8, maxScore: 15, icon: "location"),
            SecurityComponent(identifier: .timeBasedRisk, score: 5, maxScore: 5, icon: "clock")
        ]
    )
}
