//
//  InfoSection.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct InfoSection: View {
    let icon: String
    let title: String
    let color: Color
    let points: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title2)

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(color)
                            .font(.caption)
                            .frame(width: 16)

                        Text(point)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        }
    }
}

#Preview {
    InfoSection(
        icon: "lock.shield.fill",
        title: "100% Privacy-Safe",
        color: .red,
        points: [
            "No personal data collected or transmitted",
            "No user tracking or analytics",
            "All data cached locally on your device",
            "Public data sources only"
        ]
    )
}
