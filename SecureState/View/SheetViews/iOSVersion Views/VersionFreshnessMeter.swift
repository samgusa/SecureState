//
//  VersionFreshnessMeter.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct VersionFreshnessMeter: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var detector: iOSVersionDetector
    let daysSinceConfirmation: Int

    private var hasUserConfirmation: Bool {
        detector.isUserConfirmedLatest == true
    }

    private var freshnessPercentage: Double {
        guard hasUserConfirmation else { return 0.0 }
        let maxDays = 180.0 // 6 months
        let percentage = max(0, 1.0 - (Double(daysSinceConfirmation) / maxDays))
        return percentage
    }

    private var freshnessColor: Color {
        if !hasUserConfirmation { return .gray }
        switch freshnessPercentage {
        case 0.8...1.0: return themeManager.currentTheme.successColor
        case 0.5..<0.8: return themeManager.currentTheme.warningColor
        default: return themeManager.currentTheme.dangerColor
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Version Freshness")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                if hasUserConfirmation {
                    Text("\(Int(freshnessPercentage * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(freshnessColor)
                } else {
                    Text("Unconfirmed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Freshness Progress bar
            ThemedProgressBar(
                progress: freshnessPercentage,
                color: freshnessColor,
                height: 24
            )


            // Time Infomration
            VStack(spacing: 4) {
                Text("Last confirmation: \(daysSinceConfirmation) days ago")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if daysSinceConfirmation > 90 {
                    Text("Consider checking for updates - score degrades over time")
                        .font(.caption)
                        .foregroundStyle(themeManager.currentTheme.warningColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.currentTheme.warningColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding()
        .cardStyle(freshnessColor)
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    VersionFreshnessMeter(detector: iOSVersionDetector(), daysSinceConfirmation: 130)
        .environmentObject(mockThemeManager)
}
