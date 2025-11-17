//
//  EnvironmentOption.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import SwiftUI

struct EnvironmentOption: View {
    @EnvironmentObject var themeManager: ThemeManager
    let safety: EnhancedBluetoothSecurityDetector.EnvironmentSafety
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onSelect: () -> Void


    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .themedForeground(themeManager.currentTheme.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .themedForeground(themeManager.currentTheme.successColor)
                } else {
                    Circle()
                        .stroke(Color(.systemGray3), lineWidth: 1)
                        .frame(width: 20, height: 20)
                }
            }
            .padding()
            .background(
                isSelected ? color.opacity(0.1) : Color(.systemGray6)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    EnvironmentOption(
        safety: .safe,
        title: "Safe",
        description: "I recognize most devices or I'm in a trusted environment",
        icon: "checkmark.shield.fill",
        color: .green,
        isSelected: false,
        onSelect: {  }
    )
    .environmentObject(mockThemeManager)
    EnvironmentOption(
        safety: .caution,
        title: "Cautious",
        description: "Some unknown devices, but environment seems normal",
        icon: "exclamationmark.shield.fill",
        color: .orange,
        isSelected: true,
        onSelect: {  }
    )
    .environmentObject(mockThemeManager)
    EnvironmentOption(
        safety: .unsafe,
        title: "Unsafe",
        description: "Many suspicious devices or I feel exposed",
        icon: "xmark.shield.fill",
        color: .red,
        isSelected: false,
        onSelect: {  }
    )
    .environmentObject(mockThemeManager)
}
