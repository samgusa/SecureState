//
//  iOSVersionStatusView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct iOSVersionStatusView: View {
    @ObservedObject var detector: iOSVersionDetector

    private var statusColor: Color {
        let score = detector.getSecurityScore()
        let maxScore = detector.maxScore
        let percentage = Double(score) / Double(maxScore)

        if percentage >= 0.8 {
            return .green
        } else if percentage >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 60, height: 60)

                VStack(spacing: 2) {
                    Image(systemName: "iphone")
                        .font(.title2)
                        .foregroundStyle(statusColor)
                    Text("iOS")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(statusColor)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Current Version")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text("\(detector.getSecurityScore())/15")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(statusColor)
                }
                Text(detector.versionDisplayString)
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Expected latest: ~iOS \((detector.expectedVersionDisplay)).X.X")

                Text(detector.scoreExplanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    iOSVersionStatusView(detector: iOSVersionDetector())
}
