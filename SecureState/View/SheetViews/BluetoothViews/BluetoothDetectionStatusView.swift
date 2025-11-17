//
//  BluetoothDetectionStatusView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import SwiftUI

struct BluetoothDetectionStatusView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var detector: EnhancedBluetoothSecurityDetector

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(detector.bluetoothEnabled ? themeManager.currentTheme.successColor : themeManager.currentTheme.dangerColor)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Bluetooth: \(detector.bluetoothEnabled ? "Enabled" : "Disabled")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .themedForeground(themeManager.currentTheme.primary)

                    if !detector.bluetoothEnabled {
                        Text("Bluetooth disabled provides maximum security")
                            .font(.caption)
                            .themedForeground(themeManager.currentTheme.successColor)
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
                    .background(detector.isScanning ? .gray : themeManager.currentTheme.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .disabled(detector.isScanning)

                }
            }

            // Environmental Context with clearer message
            HStack {
                Image(systemName: detector.bluetoothEnabled ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                    .foregroundStyle(detector.bluetoothEnabled ? themeManager.currentTheme.primary : themeManager.currentTheme.successColor)

                Text(detector.environmentalContext)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .themedBackground(0.1)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shimmer(
                .init(
                    tint: .clear,
                    highlight: themeManager.currentTheme.accent
                ),
                animation: $detector.isScanning
            )
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    
    BluetoothDetectionStatusView(detector: .init())
        .environmentObject(mockThemeManager)
}
