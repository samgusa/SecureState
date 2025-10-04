//
//  TimeRiskStatusView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct TimeRiskStatusView: View {
    @ObservedObject var detector: TimeBasedRiskDetector

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(detector.currentTimeRisk.color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: detector.currentTimeRisk.icon)
                    .font(.title2)
                    .foregroundStyle(detector.currentTimeRisk.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(detector.timeDisplayString)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("\(detector.currentTimeRisk.rawValue)")
                        .font(.subheadline)
                        .foregroundStyle(detector.currentTimeRisk.color)
                }

                Text(detector.currentTimeRisk.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()

            VStack(alignment: .trailing) {
                Text("\(detector.getSecurityScore())/5")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(detector.currentTimeRisk.color)

                Text("Risk Score")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    TimeRiskStatusView(detector: TimeBasedRiskDetector())
}
