//
//  ComponentDetailsView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/15/25.
//

import SwiftUI
import SwiftData

struct ComponentDetailsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var proManager: ProStatusManager
    @EnvironmentObject var achievementsManager: AchievementsManager
    @Binding var securitySection: SecuritySection?
    @Binding var selectedComponentForConfirmation: SecurityComponent?
    @State private var showingConfirmationSheet: Bool = false
    @Binding var needsAttentionComponents: Set<ComponentIdentifier>
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
    let onComponentUpdate: (ComponentIdentifier, Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(securitySection?.rawValue.capitalized ?? "") Components")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .themedForeground(themeManager.currentTheme.primary)


                Spacer()

                Button("Done") {
                    withAnimation(.spring()) {
                        securitySection = nil
                    }
                }
                .font(.caption)
                .themedForeground(themeManager.currentTheme.primary)
            }

            EnhancedComponentGrid(
                deviceComponents: securitySection == .device ? realDeviceComponents : [],
                situationComponents: securitySection == .situational ? realSituationalComponents : [],
                needsAttentionComponents: needsAttentionComponents,
                onComponentTap: { component, _ in
                    onConfirm(component, true)
                },
                networkName: environmentalSecurityDetector.currentNetworkName,
                deviceLockDetector: deviceLockDetector,
                bluetoothDetector: bluetoothSecurityDetector,
                environmentDetector: environmentalSecurityDetector,
                vpnDetector: vpnDetector,
                screenRecordingDetector: screenRecordingDetector,
                iosVersionDetector: iosVersionDetector,
                timeBasedDetector: timeBasedDetector,
                onComponentUpdate: { identifier, confirmed in
                    onComponentUpdate(identifier, confirmed)
                }
            )
        }
        .padding()
        .themedBackground(0.1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .transition(
            .asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .opacity
            )
        )
    }

    func getComponents(for section: SecuritySection) -> [SecurityComponent] {
        switch section {
        case .device:
            return realDeviceComponents
        case .situational:
            return realSituationalComponents
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

        return ComponentDetailsView(
            securitySection: .constant(.situational),
            selectedComponentForConfirmation: .constant(
                SecurityComponent(
                    identifier: .deviceLock,
                    score: 10,
                    maxScore: 10,
                    icon: "key"
                )
            ),
            needsAttentionComponents: .constant([]),
            onConfirm: { a, b in

            },
            networkName: "Testing1",
            deviceLockDetector: DeviceLockSecurityDetector(),
            bluetoothSecurityDetector: EnhancedBluetoothSecurityDetector(),
            environmentalSecurityDetector: EnvironmentalSecurityDetector(),
            vpnDetector: VPNStatusDetector(),
            screenRecordingDetector: ScreenRecordingDetector(),
            iosVersionDetector: iOSVersionDetector(),
            timeBasedDetector: TimeBasedRiskDetector(),
            realDeviceComponents: [
                SecurityComponent(identifier: .vpnStatus, score: 10, maxScore: 15, icon: "shield"),
                SecurityComponent(identifier: .iosVersion, score: 8, maxScore: 10, icon: "gear"),
                SecurityComponent(identifier: .deviceLock, score: 6, maxScore: 10, icon: "wifi"),
                SecurityComponent(identifier: .screenRecording, score: 5, maxScore: 5, icon: "eye.slash")
            ],
            realSituationalComponents: [
                SecurityComponent(identifier: .environmentalSecurity, score: 8, maxScore: 25, icon: "shield"),
                SecurityComponent(identifier: .timeBasedRisk, score: 5, maxScore: 5, icon: "clock"),
                SecurityComponent(identifier: .bluetoothSecurity, score: 5, maxScore: 5, icon: "app.badge")
            ],
            onComponentUpdate: { _, _ in }

        )
        .environmentObject(freeProManager)
        .environmentObject(mockThemeManager)
        .environmentObject(achievementManager)

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

        return ComponentDetailsView(
            securitySection: .constant(.situational),
            selectedComponentForConfirmation: .constant(
                SecurityComponent(
                    identifier: .deviceLock,
                    score: 10,
                    maxScore: 10,
                    icon: "key"
                )
            ),
            needsAttentionComponents: .constant([]),
            onConfirm: { a, b in

            },
            networkName: "Testing1",
            deviceLockDetector: DeviceLockSecurityDetector(),
            bluetoothSecurityDetector: EnhancedBluetoothSecurityDetector(),
            environmentalSecurityDetector: EnvironmentalSecurityDetector(),
            vpnDetector: VPNStatusDetector(),
            screenRecordingDetector: ScreenRecordingDetector(),
            iosVersionDetector: iOSVersionDetector(),
            timeBasedDetector: TimeBasedRiskDetector(),
            realDeviceComponents: [
                SecurityComponent(identifier: .vpnStatus, score: 10, maxScore: 15, icon: "shield"),
                SecurityComponent(identifier: .iosVersion, score: 8, maxScore: 10, icon: "gear"),
                SecurityComponent(identifier: .deviceLock, score: 6, maxScore: 10, icon: "wifi"),
                SecurityComponent(identifier: .screenRecording, score: 5, maxScore: 5, icon: "eye.slash")
            ],
            realSituationalComponents: [
                SecurityComponent(identifier: .environmentalSecurity, score: 8, maxScore: 25, icon: "shield"),
                SecurityComponent(identifier: .timeBasedRisk, score: 5, maxScore: 5, icon: "clock"),
                SecurityComponent(identifier: .bluetoothSecurity, score: 5, maxScore: 5, icon: "app.badge")
            ],
            onComponentUpdate: { _, _ in }
        )
        .environmentObject(proManager)
        .environmentObject(mockThemeManager)
        .environmentObject(achievementManager)
    }()
    return view
}
