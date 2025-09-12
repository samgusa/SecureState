//
//  BluetoothDeviceCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import SwiftUI

struct BluetoothDeviceCard: View {
    let device: BluetoothDeviceInfo
    let isExpanded: Bool
    let onToggleExpanded: () -> Void

    @State private var cardScale: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            mainDeviceRow
                .contentShape(Rectangle())
                .onTapGesture {
                    handleTap()
                }
                .scaleEffect(cardScale)

            // smooth animated expanded content
            if isExpanded {
                expandedDetailsView
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity
                        ))
            }
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: isExpanded)
    }

    private var mainDeviceRow: some View {
        HStack(spacing: 12) {
            // Device category icon with subtle hover effect
            ZStack {
                Circle()
                    .fill(device.deviceCategory.color.opacity(0.1))
                    .frame(width: 32, height: 32)

                Image(systemName: device.deviceCategory.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(device.deviceCategory.color)
            }
            .scaleEffect(isExpanded ? 1.05 : 1.0)

            // Device Info
            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(device.estimatedDistance.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            // Risk Indicator with subtle pulse for high risk
            HStack(spacing: 4) {
                Circle()
                    .fill(device.riskLevel.color)
                    .frame(width: 8, height: 8)
                    .scaleEffect(device.riskLevel == .high && isExpanded ? 1.2 : 1.0)

                Text(device.riskLevel.description)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(device.riskLevel.color)
            }

            // Smooth chevron rotation
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var expandedDetailsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 8) {
                // all these values are no pre-cached, so no computation during animation
                DetailRow(
                    label: "Signal Strength",
                    value: "\(device.signalStengthDescription) (\(device.rssi) dBm)"
                )

                DetailRow(
                    label: "Estimated Distance",
                    value: device.estimatedDistance.description
                )

                if device.isSuspicious { // pre-cached boolean check
                    DetailRow(
                        label: "Risk Factor",
                        value: "Suspicious name pattern",
                        valueColor: .red
                    )
                }

                if device.isActiveScanning {
                    DetailRow(
                        label: "Activity",
                        value: "Active scanning/advertising",
                        valueColor: .orange
                    )
                }

                DetailRow(
                    label: "Discovered",
                    value: device.discoveredAt.formatted(date: .omitted, time: .shortened)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

        }
    }

    private var cardBackground: some View {
        let isHighRisk = device.riskLevel == .high

        return RoundedRectangle(cornerRadius: 8)
            .fill(isHighRisk ? Color.red.opacity(0.05) : Color(.systemBackground))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isHighRisk ? Color.red.opacity(0.3) : Color(.systemGray4),
                        lineWidth: isHighRisk ? 1.5 : 0.5
                    )
            }
            .shadow(
                color: isHighRisk ? .red.opacity(0.1) : .black.opacity(0.05),
                radius: isExpanded ? 4 : 2,
                x: 0,
                y: isExpanded ? 2 : 1
            )
    }

    private func handleTap() {
        // Light haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        // bried scale animation for tactile feedback
        withAnimation(.easeInOut(duration: 0.1)) {
            cardScale = 0.98
        }

        // Trigger expansion - all animation will be smooth because data is cached
        onToggleExpanded()

        // Reset scale
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                cardScale = 1.0
            }
        }
    }

    private struct DetailRow: View {
        let label: String
        let value: String
        var valueColor: Color = .secondary

        var body: some View {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(valueColor)
            }
        }
    }
}

