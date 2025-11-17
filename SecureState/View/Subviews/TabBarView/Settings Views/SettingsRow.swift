//
//  SettingsRow.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/8/25.
//

import SwiftUI

struct SettingsRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .themedForeground(themeManager.currentTheme.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    SettingsRow(
        icon: "checkmark.circle.fill",
        title: "Debug Pro Mode",
        subtitle: "Enabled",
        color: mockThemeManager.currentTheme.successColor
    )
        .environmentObject(mockThemeManager)

    SettingsRow(
        icon: "xmark.circle.fill",
        title: "Debug Pro Mode",
        subtitle: "Disabled",
        color: mockThemeManager.currentTheme.dangerColor
    )
        .environmentObject(mockThemeManager)
}
