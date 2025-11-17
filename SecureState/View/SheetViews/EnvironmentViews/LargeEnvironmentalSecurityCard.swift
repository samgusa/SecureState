//
//  LargeEnvironmentalSecurityCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/25/25.
//

import SwiftUI

struct LargeEnvironmentalSecurityCard: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    let component: SecurityComponent
    let needsAttention: Bool
    let environmentDetector: EnvironmentalSecurityDetector?
    let onTap: () -> Void

    @State private var pulseAnimation: Bool = false
    @State private var showDetailSheet: Bool = false

    var body: some View {
        Button(action: {
            showDetailSheet = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon and score
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
                                .themedForeground(themeManager.currentTheme.warningColor)
                                .font(.caption)
                                .background(colorScheme == .dark ? Color.black : Color.white)
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
                        .themedForeground(themeManager.currentTheme.primary)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                }

                // Progress bar
                ThemedProgressBar(
                    progress: component.percentage,
                    color: needsAttention ? themeManager.currentTheme.warningColor : component.status.color
                )
            }
            .padding(20)
            .background(needsAttention ? themeManager.currentTheme.warningColor.opacity(0.05) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(needsAttention ? .orange.opacity(0.3) : themeManager.currentTheme.primary.opacity(0.2), lineWidth: 1)
            }
            .buttonStyle(PlainButtonStyle())
            .onAppear {
                if needsAttention {
                    pulseAnimation = true
                }
            }
            .sheet(isPresented: $showDetailSheet) {
                if let detector = environmentDetector {
                    let config = ComponentConfiguration.create(
                        for: component,
                        networkName: detector.currentNetworkName,
                        environmentalDetector: detector
                    )

                    ComponentConfirmationSheet(
                        component: component,
                        config: config,
                        onConfirm: { confirmed in
                            onTap()
                            showDetailSheet = false
                        },
                        onDismiss: { showDetailSheet = false },
                        networkName: detector.currentNetworkName,
                        deviceLockDetector: nil,
                        bluetoothDetector: nil,
                        environmentDetector: detector,
                        vpnDetector: nil,
                        screenRecordingDetector: nil,
                        iosVersionDetector: nil,
                        timeBasedDetector: nil
                    )
                }
            }
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    LargeEnvironmentalSecurityCard(
        component: SecurityComponent(
            identifier: .environmentalSecurity,
            score: 23,
            maxScore: 25,
            icon: "shield"
        ),
        needsAttention: false,
        environmentDetector: EnvironmentalSecurityDetector(),
        onTap: { }
    )
    .environmentObject(mockThemeManager)
}
