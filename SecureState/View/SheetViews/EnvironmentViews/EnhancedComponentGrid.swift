//
//  EnhancedComponentGrid.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/25/25.
//

import SwiftUI

struct EnhancedComponentGrid: View {
    let deviceComponents: [SecurityComponent]
    let situationComponents: [SecurityComponent]
    let needsAttentionComponents: Set<ComponentIdentifier>
    let onComponentTap: (SecurityComponent, Bool) -> Void
    let networkName: String
    let deviceLockDetector: DeviceLockSecurityDetector?
    let bluetoothDetector: EnhancedBluetoothSecurityDetector?
    let environmentDetector: EnvironmentalSecurityDetector?
    let vpnDetector: VPNStatusDetector?
    let screenRecordingDetector: ScreenRecordingDetector?
    let iosVersionDetector: iOSVersionDetector?
    let timeBasedDetector: TimeBasedRiskDetector?
    let onComponentUpdate: (ComponentIdentifier, Bool) -> Void


    var body: some View {
        VStack(spacing: 12) {
            if !deviceComponents.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(deviceComponents, id: \.name) { component in
                        ComponentCard(
                            component: component,
                            needsAttention: needsAttentionComponents.contains(component.identifier),
                            networkName: networkName,
                            deviceLockDetector: deviceLockDetector,
                            bluetoothDetector: bluetoothDetector,
                            environmentalDetector: environmentDetector,
                            vpnDetector: vpnDetector,
                            screenRecordingDetector: screenRecordingDetector,
                            iosVersionDetector: iosVersionDetector,
                            timeBasedDetector: timeBasedDetector,
                            onUpdate: onComponentUpdate
                        )
                    }
                }
            }

            if !situationComponents.isEmpty {
                VStack(spacing: 12) {
                    // Find Environment Security Component
                    if let environmentalComponent = situationComponents.first(where: { $0.identifier == .environmentalSecurity }) {
                        LargeEnvironmentalSecurityCard(
                            component: environmentalComponent,
                            needsAttention: needsAttentionComponents.contains(environmentalComponent.identifier),
                            environmentDetector: environmentDetector,
                            onTap: {
                                onComponentTap(environmentalComponent, false)
                            }
                        )
                    }

                    // Other situational components in standard 2x2 grid
                    let otherSituationalComponents = situationComponents.filter { $0.identifier != .environmentalSecurity }
                    if !otherSituationalComponents.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(otherSituationalComponents, id: \.identifier) { component in
                                ComponentCard(
                                    component: component,
                                    needsAttention: needsAttentionComponents.contains(component.identifier),
                                    networkName: networkName,
                                    deviceLockDetector: deviceLockDetector,
                                    bluetoothDetector: bluetoothDetector,
                                    environmentalDetector: environmentDetector,
                                    vpnDetector: vpnDetector,
                                    screenRecordingDetector: screenRecordingDetector,
                                    iosVersionDetector: iosVersionDetector,
                                    timeBasedDetector: timeBasedDetector,
                                    onUpdate: onComponentUpdate
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    EnhancedComponentGrid(
        deviceComponents: [],
        situationComponents: [],
        needsAttentionComponents: [],
        onComponentTap: { _, _ in
        },
        networkName: "",
        deviceLockDetector: DeviceLockSecurityDetector(),
        bluetoothDetector: EnhancedBluetoothSecurityDetector(),
        environmentDetector: EnvironmentalSecurityDetector(),
        vpnDetector: VPNStatusDetector(),
        screenRecordingDetector: ScreenRecordingDetector(),
        iosVersionDetector: iOSVersionDetector(),
        timeBasedDetector: TimeBasedRiskDetector(),
        onComponentUpdate: { _, _ in }
    )
}
