//
//  BluetoothDeviceListView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import SwiftUI

struct BluetoothDeviceListView: View {
    @ObservedObject var detector: EnhancedBluetoothSecurityDetector
    @State private var expandedDevices: Set<UUID> = []

    private var sortedDevices: [BluetoothDeviceInfo] {
        detector.nearbyDevices.sorted { device1, device2 in
            if device1.riskLevel != device2.riskLevel {
                return device1.riskLevel == .high
            }
            return device1.rssi > device2.rssi
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nearby Devices (\(detector.nearbyDevices.count))")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                riskSummaryView
            }

            // Use regular VStack for better control (LazyVstack can cause touch issues)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(sortedDevices) { device in
                        BluetoothDeviceCard(
                            device: device,
                            isExpanded: expandedDevices.contains(device.id)) {
                                toggleDeviceExpansion(device.id)
                            }
                            .id(device.id)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 300)
        }
    }

    private var riskSummaryView: some View {
        let riskCounts = getRiskSummary()

        return HStack(spacing: 4) {
            if riskCounts.high > 0 {
                RiskBadge(count: riskCounts.high, color: .red, label: "High")
            }
            if riskCounts.medium > 0 {
                RiskBadge(count: riskCounts.medium, color: .orange, label: "Medium")
            }
            if riskCounts.low > 0 {
                RiskBadge(count: riskCounts.low, color: .green, label: "Low")
            }
        }
    }

    // MARK: - Simplified Toggle Logic
    private func toggleDeviceExpansion(_ deviceId: UUID) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if expandedDevices.contains(deviceId) {
                expandedDevices.remove(deviceId)
            } else {
                // Allow only one expanded at a time to prevent performance issues
                expandedDevices.removeAll()
                expandedDevices.insert(deviceId)
            }
        }
    }

    private func getRiskSummary() -> (high: Int, medium: Int, low: Int) {
        let devices = detector.nearbyDevices
        let high = devices.filter { $0.riskLevel == .high }.count
        let medium = devices.filter { $0.riskLevel == .medium }.count
        let low = devices.filter { $0.riskLevel == .low }.count
        return (high, medium, low)
    }
}

#Preview {
    BluetoothDeviceListView(
        detector: .init()
    )
}
