//
//  SecurityMiniCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct SecurityMiniCard: View {
    let title: String
    let score: Int
    let maxScore: Int
    let color: Color
    let action: () -> Void

    var percentage: Double {
        Double(score) / Double(maxScore)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(score)/\(maxScore)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                            .clipShape(RoundedRectangle(cornerRadius: 3))

                        Rectangle()
                            .fill(color)
                            .frame(
                                width: geometry.size.width * percentage,
                                height: 6
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
                .frame(height: 6)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SecurityMiniCard(
        title: "Device",
        score: 15,
        maxScore: 20,
        color: .gray
    ) {

    }
}
