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
        Text("\(score)")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(Circle().fill(.blue))
            .scaleEffect(isSelected ? 1.2 : 1.0)
            .opacity(0.8)
            .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    FloatingScoreIndicator(
        score: 15,
        maxScore: 20,
        isSelected: true
    )
}
