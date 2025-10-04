//
//  HourRiskExplanationView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct HourRiskExplanationView: View {
    let hour: Int
    let riskLevel: TimeBasedRiskDetector.TimeRiskLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: riskLevel.icon)
                    .foregroundStyle(riskLevel.color)

                Text("Security Risk at \(formatHour(hour))")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Text(riskLevel.description)
                .font(.body)
                .foregroundStyle(.secondary)

            // Specific guidance for the time
            Text(getTimeSpecificGuidance(for: hour, riskLevel: riskLevel))
                .font(.subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(riskLevel.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(riskLevel.color.opacity(0.3), lineWidth: 1)
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour
        let period = hour < 12 ? "AM" : "PM"
        return "\(displayHour):00 \(period)"
    }


    private func getTimeSpecificGuidance(for hour: Int, riskLevel: TimeBasedRiskDetector.TimeRiskLevel) -> String {
        switch riskLevel {
        case .high:
            return "Recommendation: Avoid important financial transactions or password changes. Consider waiting until you're more alert, or use extra verification steps."
        case .medium:
            return "Recommendation: Be extra cautious with security decisions. Double-check URLs and be more skeptical of unexpected requests."
        case .low:
            return "Optimal time for: Banking, password management, important account changes, and security-sensitive activities."
        }
    }
}

#Preview {
    HourRiskExplanationView(
        hour: 5,
        riskLevel: .high
    )
}
