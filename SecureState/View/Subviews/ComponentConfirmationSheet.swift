//
//  ComponentConfirmationSheet.swift
//  SecureState
//
//  Created by Sam Greenhill on 7/6/25.
//

import SwiftUI

struct ComponentConfirmationSheet: View {
    let component: SecurityComponent
    let onConfirm: (Bool) -> Void
    let onDismiss: () -> Void
    let networkType: String?

    private var config: (description: String, question: String, detail: String, positiveText: String, negativeText: String) {
        switch component.name {
        case "iOS Version":
            return (
                "Keeping iOS updated is crucial for security.",
                "Is your iOS version up to date?",
                "Check Settings > General > Software Update",
                "Yes, I'm up to date",
                "No, update available"
            )
        case "VPN Status":
            return (
                "A VPN encrypts your connection and protects your privacy by hiding your IP address and location.",
                "Are you currently using a VPN?",
                "Check Settings > VPN & Device Management > VPN for third-party VPNs, or Settings > Privacy & Security > iCloud Private Relay for Apple's service. \nLook for 'Connected' status or an active VPN icon in your status bar.",
                "Yes, using VPN",
                "No VPN active"
            )
        case "Screen Recording Detection":
            return (
                "Detects if screen content might be captured.",
                "Are you intentionally recording?",
                "For legitimate purposes like tutorials",
                "Yes, I'm recording",
                "No, not recording"
            )
        case "Network Type":
            let networkType = networkType ?? "current network"
            return (
                "Network security depends on whether you trust the network you're connected to.",
                "Is this \(networkType) network safe and trusted?",
                "Consider: Is this your home/work network, or a public network? Public networks pose higher security risks.",
                "Yes, it's trusted",
                "No, it's public/risky"
            )

        default:
            return (
                "This component helps protect your device.",
                "Please confirm status",
                "",
                "Yes",
                "No"
            )
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(component.status.color.opacity(0.1))
                        .frame(width: 80, height: 80)
                    Image(systemName: component.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(component.status.color)
                }

                // Content
                VStack(spacing: 16) {
                    Text(component.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(config.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Text(config.question)
                        .font(.headline)
                        .fontWeight(.medium)
                    Text(config.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                // Button
                VStack(spacing: 12) {
                    Button(config.positiveText) {
                        onConfirm(true)
                        onDismiss()
                    }
                    Button(config.negativeText) {
                        onConfirm(false)
                        onDismiss()
                    }
                }
                .padding()
                .navigationTitle("Confirm Status")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") {
                            onDismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ComponentConfirmationSheet(component: SecurityComponent(
        name: "Test",
        score: 15,
        maxScore: 20,
        icon: "shield",
        status: .good
    ),
     onConfirm: { _ in

    },
     onDismiss: {

    },
     networkType: "Testing")
}

