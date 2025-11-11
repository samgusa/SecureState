//
//  ThemePreviewCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct ThemePreviewCard: View {
    let theme: AppColorTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: {
            Haptic.tap()
            onSelect()
        }) {
            VStack(spacing: 12) {
                // Gradient Preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.previewGradient)
                    .frame(height: 100)
                    .overlay {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2)
                        }
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(theme.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .cardStyle(isSelected ? theme.primary : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
#Preview {
    ThemePreviewCard(
        theme: .default,
        isSelected: false,
        onSelect: { }
    )
}
