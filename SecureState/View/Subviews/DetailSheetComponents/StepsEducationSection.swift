//
//  StepsEducationSection.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/26/25.
//

import SwiftUI

struct StepsEducationSection: View {
    let title: String
    let icon: String
    let color: Color
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(color)
                            .frame(minWidth: 20, alignment: .leading)

                        Text(step)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
        .padding()
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    StepsEducationSection(
        title: "Title",
        icon: "wifi",
        color: .red,
        steps: []
    )
}
