//
//  LocationDetectionStatusView.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/20/25.
//

import SwiftUI

struct LocationDetectionStatusView: View {
    @ObservedObject var detector: EnhancedLocationContextDetector


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
            }

            if let suggestion = detector.smartSuggestion {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundStyle(.blue)

                    Text("Suggestion: \(suggestion.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    Spacer()
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    Home()
}
