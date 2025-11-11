//
//  FilterChip.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct FilterChip: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? themeManager.currentTheme.primary : themeManager.currentTheme.primary.opacity(0.05))
            .foregroundStyle(isSelected ? textColorWhenSelected : .primary)
            .clipShape(Capsule())
        }
    }

    private var textColorWhenSelected: Color {
        if themeManager.currentTheme == .default && colorScheme == .dark {
            return .black
        }
        return .white
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    FilterChip(
        title: "All",
        icon: nil,
        isSelected: false) { }
        .environmentObject(mockThemeManager)
}
