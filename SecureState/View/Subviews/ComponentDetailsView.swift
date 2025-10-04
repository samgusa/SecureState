//
//  ComponentDetailsView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/15/25.
//

import SwiftUI

struct ComponentDetailsView: View {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(securitySection?.rawValue.capitalized ?? "") Components")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button("Done") {
                    withAnimation(.spring()) {
                        securitySection = nil
                    }
                }
                .font(.caption)
                .foregroundStyle(.blue)
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
                timeBasedDetector: timeBasedDetector
            )
        }
        .padding()
        .background(Color(.systemGray6))
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

#Preview {
    ComponentDetailsView(
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
        ]
    )
}
