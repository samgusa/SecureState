//
//  EducationSection.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/26/25.
//

import SwiftUI

struct EducationSection: View {
    let title: String
    let icon: String
    let color: Color
    let content: String

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
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
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
    EducationSection(
        title: "Title",
        icon: "wifi",
        color: .red,
        content: "Content here"
    )
}
