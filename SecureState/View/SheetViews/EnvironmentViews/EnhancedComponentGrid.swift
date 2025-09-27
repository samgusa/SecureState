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
    let needsAttentionComponents: Set<String>
    let onComponentTap: (SecurityComponent, Bool) -> Void
    let networkName: String
    let locationDetector: EnhancedLocationContextDetector?
    let deviceLockDetector: DeviceLockSecurityDetector?
    let bluetoothDetector: EnhancedBluetoothSecurityDetector?
    let environmentDetector: EnvironmentalSecurityDetector?


    var body: some View {
        VStack(spacing: 12) {
            if !deviceComponents.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(deviceComponents, id: \.name) { component in
                        ComponentCard(
                            component: component,
                            needsAttention: needsAttentionComponents.contains(component.name),
                            onConfirm: { confirmed in
                                onComponentTap(component, true)
                            },
                            // CHANGE Remove network type
                            networkName: networkName,
                            locationDetector: locationDetector,
                            deviceLockDetector: deviceLockDetector,
                            bluetoothDetector: bluetoothDetector,
                            environmentalDetector: environmentDetector
                        )
                    }
                }
            }

            if !situationComponents.isEmpty {
                VStack(spacing: 12) {
                    // Find Environment Security Component
                    if let environmentalComponent = situationComponents.first(where: { $0.name == "Environmental Security" }) {
                        LargeEnvironmentalSecurityCard(
                            component: environmentalComponent,
                            needsAttention: needsAttentionComponents.contains(environmentalComponent.name),
                            environmentDetector: environmentDetector,
                            onTap: {
                                onComponentTap(environmentalComponent, false)
                            }
                        )
                    }

                    // Other situational components in standard 2x2 grid
                    let otherSituationalComponents = situationComponents.filter { $0.name != "Environmental Security" }
                    if !otherSituationalComponents.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(otherSituationalComponents, id: \.name) { component in
                                ComponentCard(
                                    component: component,
                                    needsAttention: needsAttentionComponents.contains(component.name),
                                    onConfirm: { confirmed in
                                        onComponentTap(component, false)
                                    },
                                    networkName: networkName,
                                    locationDetector: locationDetector,
                                    deviceLockDetector: deviceLockDetector,
                                    bluetoothDetector: bluetoothDetector,
                                    environmentalDetector: environmentDetector
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
        locationDetector: EnhancedLocationContextDetector(),
        deviceLockDetector: DeviceLockSecurityDetector(),
        bluetoothDetector: EnhancedBluetoothSecurityDetector(),
        environmentDetector: EnvironmentalSecurityDetector()
    )
}
