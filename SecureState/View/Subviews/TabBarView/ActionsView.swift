//
//  ActionsView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct ActionsView: View {
    var devicePercentage: Double
    var situationalPercentage: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                QuickActionCard(
                    icon: "shield",
                    title: "Enable VPN",
                    subtitle: "Protect your connection",
                    color: .blue,
                    isRecommended: devicePercentage < 0.7
                )
                QuickActionCard(
                    icon: "wifi.slash",
                    title: "Avoid Public Wi-Fi",
                    subtitle: "Switch to cellular data",
                    color: .orange,
                    isRecommended: situationalPercentage < 0.6
                )
                QuickActionCard(
                    icon: "gearshape",
                    title: "Update iOS",
                    subtitle: "Latest security patches",
                    color: .green,
                    isRecommended: false
                )
            }
        }
    }
}

#Preview {
    ActionsView(
        devicePercentage: 0.5,
        situationalPercentage: 0.8
    )
}
