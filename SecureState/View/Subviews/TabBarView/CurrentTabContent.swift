//
//  CurrentTabContent.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/16/25.
//

import SwiftUI
import SwiftData

struct CurrentTabContent: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var proManager: ProStatusManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var achievementsManager: AchievementsManager
    @EnvironmentObject var storeManager: EnhancedStoreManager
    @Binding var selectedSection: SecuritySection?
    @Binding var deviceScore: Double
    @Binding var situationalScore: Double
    @Binding var selectedTab: TabAction
    @Binding var selectedComponentForConfirmation: SecurityComponent?
    @Binding var needsAttentionComponents: Set<ComponentIdentifier>
    @Binding var badgeRefreshTrigger: Bool
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
    let loadRealComponents: () -> Void
    let onComponentUpdate: (ComponentIdentifier, Bool) -> Void

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
                    realSituationalComponents: realSituationalComponents,
                    onComponentUpdate: onComponentUpdate

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
        case .trends:
            if proManager.isPro {
                SecurityTrendsView(modelContext: modelContext)
            } else {
                TrendsProUpgradePrompt()
            }
        case .tips:
            SecurityTipsView()
        case .more:
            SettingsSectionView(badgeRefreshTrigger: $badgeRefreshTrigger) {
                vpnDetector.resetUserConfirmation()
                iosVersionDetector.resetUserConfirmation()
                deviceLockDetector.userConfirmedSixDigitPasscode = nil
                deviceLockDetector.userConfirmedStrongPasscode = nil
                deviceLockDetector.userConfirmedQuickAutoLock = nil
                bluetoothSecurityDetector.userEnvironmentConfirmation = nil
                environmentalSecurityDetector.networkTrustLevel = nil
                environmentalSecurityDetector.environmentType = nil

                loadRealComponents()
            }
        }
    }
}

#Preview("Free User") {
    // We wrap setup code in a closure that returns the view.
    let mockThemeManager = ThemeManager()

    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let view: some View = {
        let achievementManager = AchievementsManager(modelContext: container.mainContext)
        let mockStoreManager = EnhancedStoreManager()
        let freeProManager = ProStatusManager(storeManager: mockStoreManager)
        freeProManager.isPro = false  // not pro

        return CurrentTabContent(
            selectedSection: .constant(nil),
            deviceScore: .constant(35),
            situationalScore: .constant(28),
            selectedTab: .constant(.tips),
            selectedComponentForConfirmation: .constant(
                SecurityComponent(
                    identifier: .vpnStatus,
                    score: 10,
                    maxScore: 10,
                    icon: "key"
                )
            ),
            needsAttentionComponents: .constant([]),
            badgeRefreshTrigger: .constant(false),
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
            ], loadRealComponents: {},
            onComponentUpdate: {_, _ in }
        )
            .environmentObject(freeProManager)
            .environmentObject(mockThemeManager)
    }()
    return view
}

#Preview("Pro User") {
    let mockThemeManager = ThemeManager()

    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let view: some View = {
        let achievementManager = AchievementsManager(modelContext: container.mainContext)
        let mockStoreManager = EnhancedStoreManager()
        let proManager = ProStatusManager(storeManager: mockStoreManager, debug: true)

        return CurrentTabContent(
            selectedSection: .constant(nil),
            deviceScore: .constant(35),
            situationalScore: .constant(28),
            selectedTab: .constant(.trends),
            selectedComponentForConfirmation: .constant(
                SecurityComponent(
                    identifier: .vpnStatus,
                    score: 10,
                    maxScore: 10,
                    icon: "key"
                )
            ),
            needsAttentionComponents: .constant([]),
            badgeRefreshTrigger: .constant(false),
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
            ], loadRealComponents: {},
            onComponentUpdate: {_, _ in }
        )
            .environmentObject(proManager)
            .environmentObject(mockThemeManager)
    }()
    return view
}
