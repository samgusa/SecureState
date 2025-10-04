//
//  AlertnessMeterView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct AlertnessMeterView: View {
    let hour: Int
    let riskLevel: TimeBasedRiskDetector.TimeRiskLevel

    private var alertnessPercentage: Double {
        switch riskLevel {
        case .low: return 1.0
        case .medium: return 0.6
        case .high: return 0.2
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Expected Alertness Level")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(Int(alertnessPercentage * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(riskLevel.color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 20)

                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(riskLevel.color)
                        .frame(width: geometry.size.width * alertnessPercentage, height: 20)
                        .animation(.easeInOut(duration: 0.5), value: alertnessPercentage)
                }
            }
            .frame(height: 20)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AlertnessMeterView(
        hour: 5,
        riskLevel: .high
    )
}
