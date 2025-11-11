//
//  FloatingScoreIndicator.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct FloatingScoreIndicator: View {
    @EnvironmentObject var themeManager: ThemeManager
    let score: Int
    let maxScore: Int
    let isSelected: Bool
    @Binding var animate: Bool
    let delay: Double

    var body: some View {
        VStack(spacing: 4) {
            Text("\(score)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(scoreColor)
                .monospacedDigit() // Prevents number width changes during animation

            Text("/\(maxScore)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? scoreColor.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }

    // DONE
    private var scoreColor: Color {
        let percentage = Double(score) / Double(maxScore)
        if percentage >= 0.8 { return themeManager.currentTheme.successColor }
        if percentage >= 0.5 { return themeManager.currentTheme.warningColor }
        return themeManager.currentTheme.dangerColor
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    FloatingScoreIndicator(
        score: 15,
        maxScore: 20,
        isSelected: true,
        animate: .constant(false),
        delay: 1.0
    )
    .environmentObject(mockThemeManager)
}
