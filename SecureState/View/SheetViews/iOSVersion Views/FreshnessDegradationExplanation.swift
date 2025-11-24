//
//  FreshnessDegradationExplanation.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct FreshnessDegradationExplanation: View {
    @EnvironmentObject var themeManager: ThemeManager
    let scoringSteps: [ScoreStep] = [
        .init(
            title: "Latest Version Detected",
            scoreText: "12/15 base",
            description: "Your device is running the current major iOS version"
        ),
        .init(
            title: "+ Fresh confirmation",
            scoreText: "+3 bonus (15/15)",
            description: "Verified within 30 days"
        ),
        .init(
            title: "+ Old confirmation",
            scoreText: "+1–2 bonus",
            description: "Verified 30–90 days ago"
        ),
        .init(
            title: "+ No confirmation",
            scoreText: "+0 bonus (12/15)",
            description: "Still good score based on version"
        ),
        .init(
            title: "1 Year Behind",
            scoreText: "10/15 base",
            description: "Your iOS version is roughly one year out of date"
        ),
        .init(
            title: "3+ Years Behind",
            scoreText: "4/15 base",
            description: "Your iOS version is significantly out of date"
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .themedForeground(themeManager.currentTheme.warningColor)

                Text("How Version Scoring Works")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            Text("Your actual iOS version is the primary factor. Confirmation adds a small bonus.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(scoringSteps.enumerated()), id: \.element.id) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        VStack {
                            Circle()
                                .fill(getScoreColor(for: step))
                                .frame(width: 8, height: 8)

                            if index < scoringSteps.count - 1 {
                                Rectangle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 2, height: 20)
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(step.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Spacer()

                                Text(step.scoreText)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(getScoreColor(for: step))
                            }

                            Text(step.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

            }
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .themedForeground(themeManager.currentTheme.warningColor)
                    .font(.caption)

                Text("Confirmation freshness only affects the +0 to +3 bonus, not your base score from actual iOS version.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .cardStyle(themeManager.currentTheme.primary)
    }

    private func getScoreColor(for step: ScoreStep) -> Color {
        // Only version-based steps should have colors
        if step.title.contains("Behind") || step.title.contains("Latest Version") {
            let numbers = step.scoreText.components(
                separatedBy: CharacterSet.decimalDigits.inverted
            )
            let firstNumber = numbers.compactMap { Int($0) }.first ?? 0

            switch firstNumber {
            case 12...15: return .green      // Up to date
            case 8...11: return .orange     // 1 year behind
            case 0...7: return .red         // 2–3+ years behind
            default: return .gray
            }
        }

        // Confirmation steps → neutral color
        return .gray
    }

}

struct ScoreStep: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let scoreText: String
    let description: String
}

#Preview {
    let mockThemeManager = ThemeManager()
    FreshnessDegradationExplanation()
        .frame(width: 350, height: 350)
        .environmentObject(mockThemeManager)
}
