//
//  SettingsToggleCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/13/25.
//

import SwiftUI

struct SettingsToggleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    @State var isOn: Bool
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    SettingsToggleCard(
        icon: "key.fill",
        title: "Password Manager",
        subtitle: "Using a password manager",
        isOn: true
    )
}
