//
//  OverviewView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct OverviewView: View {

    @Binding var deviceScore: Double
    let maxDeviceScore: Double
    var devicePercentage: Double
    @Binding var situationalScore: Double
    let maxSituationalScore: Double
    var situationalPercentage: Double
    var scoreColors: [Color]
    @State var selectedSection: SecuritySection? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Security Summary")
                .font(.headline)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                SecurityMiniCard(
                    title: "Device",
                    score: Int(deviceScore),
                    maxScore: Int(maxDeviceScore),
                    color: scoreColors[0],
                    action: {
                        withAnimation(.spring()) {
                            selectedSection = .device
                        }
                    }
                )
                SecurityMiniCard(
                    title: "Situational",
                    score: Int(situationalScore),
                    maxScore: Int(maxSituationalScore),
                    color: scoreColors[1],
                    action: {
                        withAnimation(.spring()) {
                            selectedSection = .situational
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    OverviewView(
        deviceScore: .constant(22),
        maxDeviceScore: 55,
        devicePercentage: 0.5,
        situationalScore: .constant(28),
        maxSituationalScore: 45,
        situationalPercentage: 0.8,
        scoreColors: [.red, .green]
    )
}
