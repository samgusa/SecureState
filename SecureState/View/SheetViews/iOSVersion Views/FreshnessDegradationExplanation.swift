//
//  FreshnessDegradationExplanation.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct FreshnessDegradationExplanation: View {
    let scoringSteps = [
        ("Initial confirmation", "15/15 points", "When you confirm you're up to date"),
        ("After 2 months", "12/15 points", "Security updates may be available"),
        ("After 4 months", "8/15 points", "Likely missing important patches"),
        ("After 6+ months", "5/15 points", "Significantly behind current security")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(.orange)

                Text("How Freshness Scoring Works")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(scoringSteps, id: \.0) { step in
                    HStack(alignment: .top, spacing: 12) {
                        VStack {
                            Circle()
                                .fill(getScoreColor(for: step.1))
                                .frame(width: 8, height: 8)

                            if step != scoringSteps.last ?? ("", "", "") {
                                Rectangle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 2, height: 20)
                            }
                        }
                        .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(step.0)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Spacer()

                                Text(step.1)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(getScoreColor(for: step.1))
                            }

                            Text(step.2)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        }
    }

    private func getScoreColor(for scoreText: String) -> Color {
        let score = Int(scoreText.prefix(2)) ?? 0
        switch score {
        case 13...15: return .green
        case 8...12: return .orange
        default: return .red
        }
    }
}

#Preview {
    FreshnessDegradationExplanation()
        .frame(width: 350, height: 350)
}
