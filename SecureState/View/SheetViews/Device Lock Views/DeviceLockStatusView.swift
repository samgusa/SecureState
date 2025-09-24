//
//  DeviceLockStatusView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/12/25.
//

import SwiftUI

struct DeviceLockStatusView: View {
    @ObservedObject var detector: DeviceLockSecurityDetector
    var body: some View {
        VStack(spacing: 16) {
            Text("Device Security Status")
                .font(.headline)
                .fontWeight(.medium)

            VStack(spacing: 12) {
                statusCard(
                    "Biometrics",
                    detector.biometricAvailable ? "✓ \(detector.biometricTypeString) Available" : "✗ Not Available",
                    detector.biometricAvailable ? .green : .red
                )

                statusCard(
                    "Passcode",
                    detector.passcodeSet ? "✓ Passcode Set" : "✗ No Passcode",
                    detector.passcodeSet ? .green : .red
                )
            }
            infoBox("We'll test your biometric authentication and ask about your passcode setup to give you an accurate security score.")
        }
    }
}

#Preview {
    DeviceLockStatusView(detector: .init())
}
