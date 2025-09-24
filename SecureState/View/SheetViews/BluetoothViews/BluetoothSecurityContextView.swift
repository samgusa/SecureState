//
//  BluetoothSecurityContextView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/14/25.
//

import SwiftUI

struct BluetoothSecurityContextView: View {
    @ObservedObject var detector: EnhancedBluetoothSecurityDetector
    let onSelection: (EnhancedBluetoothSecurityDetector.EnvironmentSafety) -> Void

    var body: some View {
        VStack(spacing: 20) {
            BluetoothDetectionStatusView(detector: detector)

            if !detector.bluetoothEnabled {
                bluetoothDisabledView
            } else if !detector.hasScannedOnce {
                noScanYetView
            } else if detector.nearbyDevices.isEmpty && detector.hasScannedOnce && !detector.isScanning {
                noDevicesFoundView
            } else if !detector.nearbyDevices.isEmpty {
                BluetoothDeviceListView(detector: detector)
            }

            // Always show environment selection if bluetooth is enabled
            if detector.bluetoothEnabled {
                BluetoothEnvironmentSelectionView(
                    detector: detector,
                    onSelection: onSelection
                )
            } else {
                bluetoothDisabledSelectionView
            }
        }
    }

    private var bluetoothDisabledView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Maximum Security")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.green)

            Text("Bluetooth is disabled, providing the highest level of security against Bluetooth-based threats.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var noScanYetView: some View {
        VStack(spacing: 12) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Ready to Scan")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Tap 'Scan Now' above to discover nearby Bluetooth devices and assess your environment.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var noDevicesFoundView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("No Device Found")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.green)

            Text("No Bluetooth devices were discovered in your immediate area. This indicates a relatively secure environment.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var bluetoothDisabledSelectionView: some View {
        Button("Bluetooth Disabled - Maximum Security") {
            onSelection(.safe)
        }
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(.green)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    BluetoothSecurityContextView(
        detector: .init(),
        onSelection: { _ in }
    )
}
