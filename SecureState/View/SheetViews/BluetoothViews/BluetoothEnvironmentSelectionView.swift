//
//  BluetoothEnvironmentSelectionView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import SwiftUI
import Combine

struct BluetoothEnvironmentSelectionView: View {
    @ObservedObject var detector: EnhancedBluetoothSecurityDetector
    let onSelection: (EnhancedBluetoothSecurityDetector.EnvironmentSafety) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How safe does this Bluetooth environment feel")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                EnvironmentOption(
                    safety: .safe,
                    title: "Safe",
                    description: "I recognize most devices or I'm in a trusted environment",
                    icon: "checkmark.shield.fill",
                    color: .green,
                    isSelected: detector.userEnvironmentConfirmation == .safe,
                    onSelect: {
                        detector.confirmEnvironmentSafety(.safe)
                        onSelection(.safe)
                    }
                )
                EnvironmentOption(
                    safety: .caution,
                    title: "Cautious",
                    description: "Some unknown devices, but environment seems normal",
                    icon: "exclamationmark.shield.fill",
                    color: .orange,
                    isSelected: detector.userEnvironmentConfirmation == .caution,
                    onSelect: {
                        detector.confirmEnvironmentSafety(.caution)
                        onSelection(.caution)
                    }
                )
                EnvironmentOption(
                    safety: .unsafe,
                    title: "Unsafe",
                    description: "Many suspicious devices or I feel exposed",
                    icon: "xmark.shield.fill",
                    color: .red,
                    isSelected: detector.userEnvironmentConfirmation == .unsafe,
                    onSelect: {
                        detector.confirmEnvironmentSafety(.unsafe)
                        onSelection(.unsafe)
                    }
                )
            }

            if !detector.nearbyDevices.isEmpty {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)

                    Text("Your selection adjusts the security score based on your trust level of the current environment.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    BluetoothEnvironmentSelectionView(
        detector: .init(),
        onSelection: { _ in

        }
    )
}
