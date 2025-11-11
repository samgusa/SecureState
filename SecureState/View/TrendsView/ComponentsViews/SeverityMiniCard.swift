//
//  SeverityMiniCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct SeverityMiniCard: View {
    let title: String
    let count: Int
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 8) {
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                    .contentTransition(.numericText())

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .cardStyle(isSelected ? color : Color.clear, 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SeverityMiniCard(
        title: "Critical",
        count: 10,
        color: .red,
        isSelected: false
    ) { }

    SeverityMiniCard(
        title: "Critical",
        count: 5,
        color: .blue,
        isSelected: true
    ) { }
}
