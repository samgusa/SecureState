//
//  ComponentCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI
import SwiftData

struct ComponentCard: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var proManager: ProStatusManager
    @EnvironmentObject var achievementsManager: AchievementsManager
    let component: SecurityComponent
    let needsAttention: Bool
    let networkName: String
    let deviceLockDetector: DeviceLockSecurityDetector?
    let bluetoothDetector: EnhancedBluetoothSecurityDetector?
    let environmentalDetector: EnvironmentalSecurityDetector?
    let vpnDetector: VPNStatusDetector?
    let screenRecordingDetector: ScreenRecordingDetector?
    let iosVersionDetector: iOSVersionDetector?
    let timeBasedDetector: TimeBasedRiskDetector?

    let onUpdate: (ComponentIdentifier, Bool) -> Void

    @State private var pulseAnimation: Bool = false
    @State private var showConfirmationSheet: Bool = false

    var body: some View {
        Button {
            showConfirmationSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Component Icon with status overlay
                    ZStack {
                        Image(systemName: component.icon)
                            .foregroundStyle(component.status.themedColor(theme: themeManager.currentTheme))
                            .font(.title3)

                        // Attention Indicator
                        if needsAttention {
                            Image(systemName: "exclamationmark.circle.fill")
                                .themedForeground(themeManager.currentTheme.warningColor)
                                .font(.caption)
                                .background(colorScheme == .dark ? Color.black : Color.white)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
                        }
                    }

                    Spacer()

                    Text("\(component.score)/\(component.maxScore)")
                        .contentTransition(.numericText())
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }

                Text(component.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .themedForeground(themeManager.currentTheme.primary)

                // Progress bar
                ThemedProgressBar(
                    progress: Double(component.score) / Double(component.maxScore),
                    color: needsAttention ? themeManager.currentTheme.warningColor :
                        component.status.themedColor(theme: themeManager.currentTheme)
                )
            }
            .padding()
            .background(getBackgroundColor())
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        getBorderColor(),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if needsAttention {
                pulseAnimation = true
            }
        }
        .sheet(isPresented: $showConfirmationSheet) {
            achievementsManager.trackComponentViewed(component.identifier.rawValue)
        } content: {
            let config = ComponentConfiguration.create(
                for: component,
                networkName: networkName
            )

            ComponentConfirmationSheet(
                component: component,
                config: config,
                onConfirm: { confirmed in
                    onUpdate(component.identifier, confirmed)
                    showConfirmationSheet = false
                },
                onDismiss: {
                    showConfirmationSheet = false
                },
                networkName: networkName,
                deviceLockDetector: deviceLockDetector,
                bluetoothDetector: bluetoothDetector,
                environmentDetector: environmentalDetector,
                vpnDetector: vpnDetector,
                screenRecordingDetector: screenRecordingDetector,
                iosVersionDetector: iosVersionDetector,
                timeBasedDetector: timeBasedDetector
            )
        }
    }

    private func getBackgroundColor() -> Color {
        if needsAttention {
            return themeManager.currentTheme.warningColor.opacity(0.05)
        }

        let percentage = component.percentage

        if percentage >= 0.8 {
            // Good score (80%+)
            return Color(.systemBackground)
        } else if percentage >= 0.5 {
            // Medium score (50-79%)
            return themeManager.currentTheme.warningColor.opacity(0.03)
        } else {
            // Low score (below 50%)
            return themeManager.currentTheme.dangerColor.opacity(0.05)
        }
    }


    private func getBorderColor() -> Color {
        if needsAttention {
            return themeManager.currentTheme.warningColor.opacity(0.03)
        }

        let percentage = component.percentage

        if percentage >= 0.8 {
            // Good score (80%+)
            return Color(.secondarySystemBackground)
        } else if percentage >= 0.5 {
            // Medium score (50-79%)
            return themeManager.currentTheme.warningColor.opacity(0.02)
        } else {
            // Low score (below 50%)
            return themeManager.currentTheme.dangerColor.opacity(0.03)
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

        return VStack {
            ComponentCard(
                component: SecurityComponent(
                    identifier: .iosVersion,
                    score: 18,
                    maxScore: 20,
                    icon: "wifi"
                ),
                needsAttention: false,
                networkName: "Network 2",
                deviceLockDetector: DeviceLockSecurityDetector(),
                bluetoothDetector: EnhancedBluetoothSecurityDetector(),
                environmentalDetector: EnvironmentalSecurityDetector(),
                vpnDetector: VPNStatusDetector(),
                screenRecordingDetector: ScreenRecordingDetector(),
                iosVersionDetector: iOSVersionDetector(),
                timeBasedDetector: TimeBasedRiskDetector(),
                onUpdate: { _, _ in }
            )
            ComponentCard(
                component: SecurityComponent(
                    identifier: .bluetoothSecurity,
                    score: 15,
                    maxScore: 20,
                    icon: "bluetooth"
                ),
                needsAttention: true,
                networkName: "Network 2",
                deviceLockDetector: DeviceLockSecurityDetector(),
                bluetoothDetector: EnhancedBluetoothSecurityDetector(),
                environmentalDetector: EnvironmentalSecurityDetector(),
                vpnDetector: VPNStatusDetector(),
                screenRecordingDetector: ScreenRecordingDetector(),
                iosVersionDetector: iOSVersionDetector(),
                timeBasedDetector: TimeBasedRiskDetector(),
                onUpdate: { _, _ in }
            )
            ComponentCard(
                component: SecurityComponent(
                    identifier: .deviceLock,
                    score: 2,
                    maxScore: 20,
                    icon: "lock"
                ),
                needsAttention: true,
                networkName: "Network 2",
                deviceLockDetector: DeviceLockSecurityDetector(),
                bluetoothDetector: EnhancedBluetoothSecurityDetector(),
                environmentalDetector: EnvironmentalSecurityDetector(),
                vpnDetector: VPNStatusDetector(),
                screenRecordingDetector: ScreenRecordingDetector(),
                iosVersionDetector: iOSVersionDetector(),
                timeBasedDetector: TimeBasedRiskDetector(),
                onUpdate: { _, _ in }
            )
        }
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
            .environmentObject(mockStoreManager)
            .environmentObject(freeProManager)

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

        return VStack {
            ComponentCard(
                component: SecurityComponent(
                    identifier: .iosVersion,
                    score: 18,
                    maxScore: 20,
                    icon: "wifi"
                ),
                needsAttention: false,
                networkName: "Network 2",
                deviceLockDetector: DeviceLockSecurityDetector(),
                bluetoothDetector: EnhancedBluetoothSecurityDetector(),
                environmentalDetector: EnvironmentalSecurityDetector(),
                vpnDetector: VPNStatusDetector(),
                screenRecordingDetector: ScreenRecordingDetector(),
                iosVersionDetector: iOSVersionDetector(),
                timeBasedDetector: TimeBasedRiskDetector(),
                onUpdate: { _, _ in }
            )
            ComponentCard(
                component: SecurityComponent(
                    identifier: .bluetoothSecurity,
                    score: 15,
                    maxScore: 20,
                    icon: "bluetooth"
                ),
                needsAttention: true,
                networkName: "Network 2",
                deviceLockDetector: DeviceLockSecurityDetector(),
                bluetoothDetector: EnhancedBluetoothSecurityDetector(),
                environmentalDetector: EnvironmentalSecurityDetector(),
                vpnDetector: VPNStatusDetector(),
                screenRecordingDetector: ScreenRecordingDetector(),
                iosVersionDetector: iOSVersionDetector(),
                timeBasedDetector: TimeBasedRiskDetector(),
                onUpdate: { _, _ in }
            )
            ComponentCard(
                component: SecurityComponent(
                    identifier: .deviceLock,
                    score: 2,
                    maxScore: 20,
                    icon: "lock"
                ),
                needsAttention: true,
                networkName: "Network 2",
                deviceLockDetector: DeviceLockSecurityDetector(),
                bluetoothDetector: EnhancedBluetoothSecurityDetector(),
                environmentalDetector: EnvironmentalSecurityDetector(),
                vpnDetector: VPNStatusDetector(),
                screenRecordingDetector: ScreenRecordingDetector(),
                iosVersionDetector: iOSVersionDetector(),
                timeBasedDetector: TimeBasedRiskDetector(),
                onUpdate: { _, _ in }
            )
        }
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
            .environmentObject(mockStoreManager)
            .environmentObject(proManager)

    }()
    return view
}
