//
//  VPNStatusIndicatorView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct VPNStatusIndicatorView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var detector: VPNStatusDetector

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(detector.isVPNDetected ? themeManager.currentTheme.successColor.opacity(0.2) : themeManager.currentTheme.dangerColor.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: detector.isVPNDetected ? "shield.fill" : "shield.slash.fill")
                    .font(.title3)
                    .foregroundStyle(detector.isVPNDetected ? themeManager.currentTheme.successColor : themeManager.currentTheme.dangerColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("VPN Status Detection")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(detector.statusDisplayString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Confidence Indicator
            VStack(alignment: .trailing, spacing: 2) {
                Text("Confidence")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(detector.detectionConfidence.level)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(detector.detectionConfidence.color)
            }
        }
        .padding()
        .themedBackground(0.1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    VPNStatusIndicatorView(detector: VPNStatusDetector())
        .environmentObject(mockThemeManager)
}
