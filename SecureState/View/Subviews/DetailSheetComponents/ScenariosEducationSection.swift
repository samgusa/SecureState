//
//  ScenariosEducationSection.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/26/25.
//

import SwiftUI

struct ScenariosEducationSection: View {
    let title: String
    let icon: String
    let color: Color
    let scenarios: [String]

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
            VStack(alignment: .leading, spacing: 6) {
                ForEach(scenarios, id: \.self) { scenario in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(color)

                        Text(scenario)
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
                .stroke(color.opacity((0.2)), lineWidth: 1)
        }
    }
}

#Preview {
    ScenariosEducationSection(
        title: "Title",
        icon: "wifi",
        color: .red,
        scenarios: []
    )
}
