//
//  DeviceLockStatusView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/12/25.
//

import SwiftUI

struct DeviceLockStatusView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var detector: DeviceLockSecurityDetector

    var body: some View {
        VStack(spacing: 16) {
            Text("Device Security Status")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(themeManager.currentTheme.primary)

            VStack(spacing: 12) {
                statusCard(
                    "Biometrics",
                    detector.biometricAvailable ? "✓ \(detector.biometricTypeString) Available" : "✗ Not Available",
                    detector.biometricAvailable ? themeManager.currentTheme.successColor : themeManager.currentTheme.warningColor,
                    themeManager.currentTheme.primary
                )

                statusCard(
                    "Passcode",
                    detector.passcodeSet ? "✓ Passcode Set" : "✗ No Passcode",
                    detector.passcodeSet ? themeManager.currentTheme.successColor : themeManager.currentTheme.dangerColor,
                    themeManager.currentTheme.primary
                )
            }
            infoBox("We'll test your biometric authentication and ask about your passcode setup to give you an accurate security score.", themeManager: themeManager)
        }
    }

    func statusCard(_ title: String, _ status: String, _ color: Color, _ themeColor: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(status)
                    .font(.caption)
                    .foregroundStyle(color)
            }

            Spacer()

            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
        .padding()
        .background(themeColor.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @MainActor
    private func infoBox(_ text: String, themeManager: ThemeManager) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(themeManager.currentTheme.primary)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(themeManager.currentTheme.primary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let mockThemeManager = ThemeManager()

    DeviceLockStatusView(detector: .init())
        .environmentObject(mockThemeManager)
}
