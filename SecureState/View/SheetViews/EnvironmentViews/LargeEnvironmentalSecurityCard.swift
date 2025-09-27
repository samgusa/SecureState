//
//  LargeEnvironmentalSecurityCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/25/25.
//

import SwiftUI

struct LargeEnvironmentalSecurityCard: View {
    let component: SecurityComponent
    let needsAttention: Bool
    let environmentDetector: EnvironmentalSecurityDetector?
    let onTap: () -> Void

    @State private var pulseAnimation: Bool = false
    @State private var showDetailSheet: Bool = false

    var body: some View {
        Button {
            showDetailSheet = true
        } label: {
            // Header with icon and score
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(component.status.color.opacity(0.1))
                            .frame(width: 48, height: 48)

                        Image(systemName: component.icon)
                            .foregroundStyle(component.status.color)
                            .font(.title2)

                        if needsAttention {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.orange)
                                .font(.caption)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: 16, y: -16)
                                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
                        }
                    }
                    Spacer()

                    HStack(spacing: 2) {
                        Text("\(component.score)")
                            .contentTransition(.numericText())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(component.status.color)


                        Text("/ \(component.maxScore)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }

                // Title and description
                VStack(alignment: .leading, spacing: 8) {
                    Text(component.name)
                        .foregroundStyle(.black)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                }

                // ProgressBar
                ProgressBar(
                    score: component.score,
                    maxScore: component.maxScore,
                    color: component.status.color
                )
            }
            .padding(20)
            .background(needsAttention ? Color.orange.opacity(0.05) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(needsAttention ? .orange.opacity(0.3) : Color(.systemGray3), lineWidth: 1)
            }
            .buttonStyle(PlainButtonStyle())
            .onAppear {
                if needsAttention {
                    pulseAnimation = true
                }
            }
            .sheet(isPresented: $showDetailSheet) {
                if let detector = environmentDetector {
                    // UPDATE
                    let config = ComponentConfiguration.create(
                        for: component,
                        networkName: detector.currentNetworkName,
                        locationDetector: nil //,
                        //environmentDetector: detector
                    )

                    ComponentConfirmationSheet(
                        component: component,
                        config: config,
                        onConfirm: { confirmed in
                            onTap()
                            showDetailSheet = false
                        },
                        onDismiss: { showDetailSheet = false },
                        locationDetector: nil,
                        networkName: detector.currentNetworkName,
                        deviceLockDetector: nil,
                        bluetoothDetector: nil,
                        // FIX
                        environmentDetector: EnvironmentalSecurityDetector()
                    )
                }
            }
        }
    }
}

#Preview {
    LargeEnvironmentalSecurityCard(
        component: SecurityComponent(
            name: "Environmental Section",
            score: 23,
            maxScore: 25,
            icon: "shield"
        ),
        needsAttention: true,
        environmentDetector: EnvironmentalSecurityDetector(),
        onTap: { }
    )
}
