//
//  HeaderView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct HeaderView: View {
    let isRefreshing: Bool
    let lastRefreshTime: Date
    let securityStatusIcon: String
    let securityStatusColor: Color
    let securityStatusMessage: String
    let overallPercentage: Double
    let performRefresh: () async -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How Secure are you right now?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    HStack {
                        Image(systemName: securityStatusIcon)
                            .foregroundStyle(securityStatusColor)
                        Text(securityStatusMessage)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(securityStatusColor)
                    }
                }
                Spacer()

                // Refresh Button
                Button(action: {
                    Task {
                        await performRefresh()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                        .animation(.linear(duration: 1).repeatCount(isRefreshing ? 10 : 1, autoreverses: false), value: isRefreshing)
                }
                .disabled(isRefreshing)
            }

            // Last Refresh Time
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                Text("Last updated: \(lastRefreshTime.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if overallPercentage < 0.6 {
                    Text("Action needed")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HeaderView(
        isRefreshing: false,
        lastRefreshTime: Date.now,
        securityStatusIcon: "shield",
        securityStatusColor: .green,
        securityStatusMessage: "Secure",
        overallPercentage: 0.7,
        performRefresh: { }
    )
    .padding(.bottom, 50)

    HeaderView(
        isRefreshing: false,
        lastRefreshTime: Date.now,
        securityStatusIcon: "shield",
        securityStatusColor: .green,
        securityStatusMessage: "Secure",
        overallPercentage: 0.5,
        performRefresh: { }
    )
}
