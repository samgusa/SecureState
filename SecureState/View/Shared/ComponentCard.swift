//
//  ComponentCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct ComponentCard: View {
    let component: SecurityComponent
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: component.icon)
                    .foregroundStyle(component.status.color)
                    .font(.title3)

                Spacer()

                Text("\(component.score)/\(component.maxScore)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            Text(component.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 2))

                    Rectangle()
                        .fill(component.status.color)
                        .frame(width: geometry.size.width * component.percentage, height: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                        .animation(.easeInOut(duration: 0.8), value: component.percentage)
                }
            }
            .frame(height: 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ComponentCard(
        component: SecurityComponent(
            name: "Test",
            score: 15,
            maxScore: 20,
            icon: "shield",
            status: .good
        )
    )
}
