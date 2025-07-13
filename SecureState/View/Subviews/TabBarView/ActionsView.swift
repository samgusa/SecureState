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
                UniversalCard(
                    icon: "shield",
                    title: "Enable VPN",
                    subtitle: "Protect your connection",
                    style: .action(.blue, devicePercentage < 0.7)
                )

                UniversalCard(
                    icon: "wifi.slash",
                    title: "Avoid Public Wi-Fi",
                    subtitle: "Switch to cellular data",
                    style: .action(.orange, situationalPercentage < 0.6)
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
