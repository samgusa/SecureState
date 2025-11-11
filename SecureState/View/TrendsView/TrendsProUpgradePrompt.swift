//
//  TrendsProUpgradePrompt.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/8/25.
//

import SwiftUI

struct TrendsProUpgradePrompt: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [themeManager.currentTheme.warningColor, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
            }
            Text("Global Security Trends")
                .font(.title2)
                .fontWeight(.bold)

            Text("Track worldwide cybersecurity activity with real-time breach and vulnerability data.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                FeatureBullet(icon: "chart.bar.fill", text: "Real-time breach tracking", color: themeManager.currentTheme.warningColor)
                FeatureBullet(icon: "shield.fill", text: "CVE vulnerability monitoring", color: themeManager.currentTheme.dangerColor)
                FeatureBullet(icon: "clock.fill", text: "90-day trend history", color: themeManager.currentTheme.primary)
                FeatureBullet(icon: "lock.fill", text: "100% privacy-safe", color: themeManager.currentTheme.successColor)
            }
            .padding()
            .themedBackground(0.1)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                // NEED TO SET UP
            } label: {
                Text("Upgrade to Pro")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [themeManager.currentTheme.warningColor, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    TrendsProUpgradePrompt()
        .environmentObject(mockThemeManager)
}
