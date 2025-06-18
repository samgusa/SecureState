//
//  ScoreCardView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct ScoreCardView: View {
    @Binding var animateScore: Bool
    var overallPercentage: Double
    var overallScoreColor: Color
    var securityStatusMessage: String
    var securityStatusColor: Color
    var totalScore: Double
    var totalMaxScore: Int
    var securityAdvice: String


    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Score circle visualization
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: animateScore ? overallPercentage: 0)
                        .stroke(overallScoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.5), value: animateScore)

                    VStack(spacing: 2) {
                        Text("\(Int(overallPercentage * 100))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(overallScoreColor)
                        Text("%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(securityStatusMessage)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(securityStatusColor)
                    Text("Current protection level")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(Int(totalScore))/\(Int(totalMaxScore)) points")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            // Security advice based on score
            if overallPercentage < 0.7 {
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(.orange)
                    Text(securityAdvice)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(overallScoreColor.opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    ScoreCardView(
        animateScore: .constant(true),
        overallPercentage: 0.8,
        overallScoreColor: .green,
        securityStatusMessage: "Good Protection",
        securityStatusColor: .mint,
        totalScore: 69,
        totalMaxScore: 80,
        securityAdvice: "Focus on device security - enable VPN and update iOS"
    )
    .padding(.bottom, 15)
    ScoreCardView(
        animateScore: .constant(true),
        overallPercentage: 0.5,
        overallScoreColor: .red,
        securityStatusMessage: "Good Protection",
        securityStatusColor: .red,
        totalScore: 49,
        totalMaxScore: 80,
        securityAdvice: "Focus on device security - enable VPN and update iOS"
    )
}
