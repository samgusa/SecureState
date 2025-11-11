//
//  MetricCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct MetricCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let value: Int
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                }

                VStack(spacing: 4) {
                    Text("\(value)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                        .contentTransition(.numericText())

                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .cardStyle(isSelected ? color : Color.clear, 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MetricCard(
        icon: "exclamationmark.shield",
        title: "Total Vulnerabilities",
        subtitle: "Last 7 Days (Estimated)",
        value: 10,
        color: .blue,
        isSelected: false
    ) { }

    MetricCard(
        icon: "exclamationmark.shield",
        title: "Total Vulnerabilities",
        subtitle: "Last 7 Days (Estimated)",
        value: 10,
        color: .blue,
        isSelected: true
    ) { }
}
