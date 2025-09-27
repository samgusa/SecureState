//
//  EnvironmentLocationDetectionStatusView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/25/25.
//

import SwiftUI

struct EnvironmentLocationDetectionStatusView: View {
    @ObservedObject var detector: EnvironmentalSecurityDetector

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(detector.detectionConfidence.color)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Detection: \(detector.detectionConfidence.level)")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(detector.detectionConfidence.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if detector.hasLocationPermission {
                    Button("Refresh Location") {
                        detector.performLocationSnapshot()
                    }
                    .font(.caption)
                    .foregroundStyle(.blue)
                } else {
                    Button("Enable Location") {
                        detector.requestLocationPermission()
                    }
                    .font(.caption)
                    .foregroundStyle(.blue)
                }
            }

            if let suggestion = detector.smartSuggestion {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundStyle(.blue)

                    Text("Suggestion: \(suggestion.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    Spacer()

                    Button("Use") {
                        detector.selectEnvironmentType(suggestion)
                    }
                    .font(.caption)
                    .foregroundStyle(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    EnvironmentLocationDetectionStatusView(detector: EnvironmentalSecurityDetector())
}
