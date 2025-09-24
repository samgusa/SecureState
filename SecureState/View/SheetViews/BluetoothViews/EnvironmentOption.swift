//
//  EnvironmentOption.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import SwiftUI

struct EnvironmentOption: View {
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
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
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
    EnvironmentOption(
        safety: .caution,
        title: "Caution",
        description: "This is a caution",
        icon: "wifi",
        color: .red,
        isSelected: false,
        onSelect: {

        }
    )
}
