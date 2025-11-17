//
//  OverviewView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct OverviewView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var deviceScore: Double
    let maxDeviceScore: Double
    var devicePercentage: Double
    @Binding var situationalScore: Double
    let maxSituationalScore: Double
    var situationalPercentage: Double
    var scoreColors: [Color]
    @Binding var selectedSection: SecuritySection?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Security Summary")
                .font(.headline)
                .fontWeight(.semibold)
                .themedForeground(themeManager.currentTheme.primary)

            HStack(spacing: 16) {
                UniversalCard(
                    title: "Device",
                    style: .score(Int(deviceScore), Int(maxDeviceScore), scoreColors[0], {
                        withAnimation(.spring()) {
                            selectedSection = .device
                        }
                    })
                )

                UniversalCard(
                    title: "Situational",
                    style: .score(Int(situationalScore), Int(maxSituationalScore), scoreColors[1], {
                        withAnimation(.spring()) {
                            selectedSection = .situational
                        }
                    })
                )
            }
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    OverviewView(
        deviceScore: .constant(22),
        maxDeviceScore: 55,
        devicePercentage: 0.5,
        situationalScore: .constant(28),
        maxSituationalScore: 45,
        situationalPercentage: 0.8,
        scoreColors: [.red, .green],
        selectedSection: .constant(.device)
    )
    .environmentObject(mockThemeManager)
}
