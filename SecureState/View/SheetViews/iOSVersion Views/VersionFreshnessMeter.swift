//
//  VersionFreshnessMeter.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct VersionFreshnessMeter: View {
    @ObservedObject var detector: iOSVersionDetector
    let daysSinceConfirmation: Int

    private var hasUserConfirmation: Bool {
        detector.isUserConfirmedLatest == true
    }

    private var freshnessPercentage: Double {
        guard hasUserConfirmation else { return 0.0 }
        let maxDays = 180.0 // 6 months
        let percentage = max(0, 1.0 - (Double(daysSinceConfirmation) / maxDays))
        return percentage
    }

    private var freshnessColor: Color {
        if !hasUserConfirmation { return .gray }
        switch freshnessPercentage {
        case 0.8...1.0: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Version Freshness")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                if hasUserConfirmation {
                    Text("\(Int(freshnessPercentage * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(freshnessColor)
                } else {
                    Text("Unconfirmed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Freshness Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(height: 24)

                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            colors: [freshnessColor.opacity(0.7), freshnessColor],
                            startPoint: .leading,
                            endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * freshnessPercentage, height: 24)
                        .animation(.easeInOut(duration: 0.8), value: freshnessPercentage)
                }
            }
            .frame(height: 24)


            // Time Infomration
            VStack(spacing: 4) {
                Text("Last confirmation: \(daysSinceConfirmation) days ago")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if daysSinceConfirmation > 90 {
                    Text("Consider checking for updates - score degrades over time")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(freshnessColor.opacity(0.3), lineWidth: 1)
        }
    }
}

#Preview {
    VersionFreshnessMeter(detector: iOSVersionDetector(), daysSinceConfirmation: 130)
}
