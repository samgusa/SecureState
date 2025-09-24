//
//  BluetoothDetectionStatusView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import SwiftUI

struct BluetoothDetectionStatusView: View {
    @ObservedObject var detector: EnhancedBluetoothSecurityDetector

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(detector.bluetoothEnabled ? .green : .red)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Bluetooth: \(detector.bluetoothEnabled ? "Enabled" : "Diabled")")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if !detector.bluetoothEnabled {
                        Text("Bluetooth disabled provides maximum security")
                            .font(.caption)
                            .foregroundStyle(.green)
                    } else if !detector.hasScannedOnce {
                        Text("Scan to assess Bluetooth environment")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if detector.isScanning {
                        Text("Scanning for nearby devices...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Last scan: \(detector.lastScanTime?.formatted(date: .omitted, time: .shortened) ?? "Never")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if detector.bluetoothEnabled {
                    Button(detector.isScanning ? "Scanning..." : "Scan Now") {
                        if !detector.isScanning {
                            detector.startScanning()
                        }
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(detector.isScanning ? .gray : .blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .disabled(detector.isScanning)
                }
            }

            // Environmental Context with clearer message
            HStack {
                Image(systemName: detector.bluetoothEnabled ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                    .foregroundStyle(detector.bluetoothEnabled ? .blue : .green)

                Text(detector.environmentalContext)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shimmer(
                .init(
                    tint: .clear,
                    highlight: Color(.white).opacity(0.8)
                ),
                animation: $detector.isScanning
            )
        }
    }
}

#Preview {
    BluetoothDetectionStatusView(
        detector: .init()
    )
}
