//
//  FloatingScoreIndicator.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct FloatingScoreIndicator: View {
    let score: Int
    let maxScore: Int
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("\(score)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(scoreColor)
                .monospacedDigit()

            Text("/\(maxScore)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? scoreColor : Color.clear, lineWidth: 2)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }

    private var scoreColor: Color {
        let percentage = Double(score) / Double(maxScore)
        if percentage >= 0.8 { return .green }
        if percentage >= 0.5 { return .orange }
        return .red
    }
}

#Preview {
    FloatingScoreIndicator(
        score: 15,
        maxScore: 20,
        isSelected: true
    )
}
