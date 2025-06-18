//
//  SettingsTabView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/15/25.
//

import SwiftUI

struct SettingsTabView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
                .fontWeight(.semibold)
            VStack(spacing: 8) {
                SettingsToggleCard(
                    icon: "key.fill",
                    title: "Password Manager",
                    subtitle: "Using a password manager",
                    isOn: true
                )

                SettingsToggleCard(
                    icon: "lock.fill",
                    title: "Device Lock",
                    subtitle: "Password or biometric lock enabled",
                    isOn: true
                )
            }
        }
    }
}

#Preview {
    SettingsTabView()
}
