//
//  ComponentCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct ComponentCard: View {
    let component: SecurityComponent
    let needsAttention: Bool
    let onConfirm: (Bool) -> Void
    let networkName: String
    let locationDetector: EnhancedLocationContextDetector?
    let deviceLockDetector: DeviceLockSecurityDetector?
    let bluetoothDetector: EnhancedBluetoothSecurityDetector?

    @State private var pulseAnimation: Bool = false
    @State private var showConfirmationSheet: Bool = false

    var body: some View {
        Button {
            if needsAttention {
                showConfirmationSheet = true
            } else {
                onConfirm(true)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Component Icon with status overlay
                    ZStack {
                        Image(systemName: component.icon)
                            .foregroundStyle(component.status.color)
                            .font(.title3)

                        // Attention Indicator
                        if needsAttention {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.orange)
                                .font(.caption)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
                        }
                    }

                    Spacer()

                    Text("\(component.score)/\(component.maxScore)")
                        .contentTransition(.numericText())
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                }

                Text(component.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 4)
                            .clipShape(RoundedRectangle(cornerRadius: 2))

                        Rectangle()
                            .fill(needsAttention ? .orange : component.status.color)
                            .frame(width: geometry.size.width * component.percentage, height: 4)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                            .animation(.easeInOut(duration: 0.8), value: component.percentage)
                    }
                }
                .frame(height: 4)
            }
            .padding()
            .background(needsAttention ? Color.orange.opacity(0.05) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if needsAttention {
                pulseAnimation = true
            }
        }
        .sheet(isPresented: $showConfirmationSheet) {
            bluetoothDetector?.clearCache()
        } content: {
            let config = ComponentConfiguration.create(
                for: component,
                networkName: networkName,
                locationDetector: locationDetector
            )

            ComponentConfirmationSheet(
                component: component,
                config: config,
                onConfirm: { confirmed in
                    onConfirm(confirmed)
                    showConfirmationSheet = false
                },
                onDismiss: {
                    showConfirmationSheet = false
                },
                locationDetector: locationDetector,
                networkName: networkName,
                deviceLockDetector: deviceLockDetector,
                bluetoothDetector: bluetoothDetector
            )
        }
    }
}

#Preview {
    ComponentCard(
        component: SecurityComponent(
            name: "Wifi",
            score: 18,
            maxScore: 20,
            icon: "wifi"
        ),
        needsAttention: false,
        onConfirm: { _ in },
        networkName: "Network 2",
        locationDetector: EnhancedLocationContextDetector(),
        deviceLockDetector: DeviceLockSecurityDetector(),
        bluetoothDetector: EnhancedBluetoothSecurityDetector()
    )
    ComponentCard(
        component: SecurityComponent(
            name: "Wifi",
            score: 15,
            maxScore: 20,
            icon: "wifi"
        ),
        needsAttention: true,
        onConfirm: { _ in },
        networkName: "Network 2",
        locationDetector: EnhancedLocationContextDetector(),
        deviceLockDetector: DeviceLockSecurityDetector(),
        bluetoothDetector: EnhancedBluetoothSecurityDetector()
    )
    ComponentCard(
        component: SecurityComponent(
            name: "Wifi",
            score: 2,
            maxScore: 20,
            icon: "wifi"
        ),
        needsAttention: true,
        onConfirm: { _ in },
        networkName: "Network 2",
        locationDetector: EnhancedLocationContextDetector(),
        deviceLockDetector: DeviceLockSecurityDetector(),
        bluetoothDetector: EnhancedBluetoothSecurityDetector()
    )
}
