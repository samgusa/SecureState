//
//  ComponentCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct ComponentCard: View {
    let component: SecurityComponent
    let needsAttention: Bool
    let onConfirm: (Bool) -> Void
    let networkName: String
    let deviceLockDetector: DeviceLockSecurityDetector?
    let bluetoothDetector: EnhancedBluetoothSecurityDetector?
    let environmentalDetector: EnvironmentalSecurityDetector?
    let vpnDetector: VPNStatusDetector?
    let screenRecordingDetector: ScreenRecordingDetector?
    let iosVersionDetector: iOSVersionDetector?
    let timeBasedDetector: TimeBasedRiskDetector?

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
                            .foregroundStyle(component.status.color)
                            .font(.title3)

                        // Attention Indicator
                        if needsAttention {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.orange)
                                .font(.caption)
                                .background(Color.white)
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
                    .foregroundStyle(.primary)

                // Progress bar
                ProgressBar(score: component.score, maxScore: component.maxScore, color: needsAttention ? .orange : component.status.color)
            }
            .padding()
            .background(needsAttention ? Color.orange.opacity(0.05) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if needsAttention {
                pulseAnimation = true
            }
        }
        .sheet(isPresented: $showConfirmationSheet) {
            bluetoothDetector?.clearCache()
        } content: {
            let config = ComponentConfiguration.create(
                for: component,
                networkName: networkName
            )

            ComponentConfirmationSheet(
                component: component,
                config: config,
                onConfirm: { confirmed in
                    onConfirm(confirmed)
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
}

#Preview {
    ComponentCard(
        component: SecurityComponent(
            identifier: .iosVersion,
            score: 18,
            maxScore: 20,
            icon: "wifi"
        ),
        needsAttention: false,
        onConfirm: { _ in },
        networkName: "Network 2",
        deviceLockDetector: DeviceLockSecurityDetector(),
        bluetoothDetector: EnhancedBluetoothSecurityDetector(),
        environmentalDetector: EnvironmentalSecurityDetector(),
        vpnDetector: VPNStatusDetector(),
        screenRecordingDetector: ScreenRecordingDetector(),
        iosVersionDetector: iOSVersionDetector(),
        timeBasedDetector: TimeBasedRiskDetector()
    )
    ComponentCard(
        component: SecurityComponent(
            identifier: .bluetoothSecurity,
            score: 15,
            maxScore: 20,
            icon: "bluetooth"
        ),
        needsAttention: true,
        onConfirm: { _ in },
        networkName: "Network 2",
        deviceLockDetector: DeviceLockSecurityDetector(),
        bluetoothDetector: EnhancedBluetoothSecurityDetector(),
        environmentalDetector: EnvironmentalSecurityDetector(),
        vpnDetector: VPNStatusDetector(),
        screenRecordingDetector: ScreenRecordingDetector(),
        iosVersionDetector: iOSVersionDetector(),
        timeBasedDetector: TimeBasedRiskDetector()
    )
    ComponentCard(
        component: SecurityComponent(
            identifier: .deviceLock,
            score: 2,
            maxScore: 20,
            icon: "lock"
        ),
        needsAttention: true,
        onConfirm: { _ in },
        networkName: "Network 2",
        deviceLockDetector: DeviceLockSecurityDetector(),
        bluetoothDetector: EnhancedBluetoothSecurityDetector(),
        environmentalDetector: EnvironmentalSecurityDetector(),
        vpnDetector: VPNStatusDetector(),
        screenRecordingDetector: ScreenRecordingDetector(),
        iosVersionDetector: iOSVersionDetector(),
        timeBasedDetector: TimeBasedRiskDetector()
    )
}
