//
//  VPNTrafficSimulatorView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct VPNTrafficSimulatorView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var detector: VPNStatusDetector
    let onSelection: (Bool) -> Void

    @State private var isSimulating: Bool = false
    @State private var showWithVPN: Bool = false
    @State private var animatingPackets: [PacketAnimation] = []
    @State private var interceptedData: [String] = []
    @State private var packetProgress: [UUID: Double] = [:]

    struct PacketAnimation: Identifiable {
        let id = UUID()
        let data: String
        let isEncrypted: Bool
        var progress: Double = 0.0
    }

    var body: some View {
        VStack(spacing: 24) {
            // Current VPN Status
            VPNStatusIndicatorView(detector: detector)

            // Traffic Simulator Header
            VStack(spacing: 12) {
                Text("Traffic Encryption Simulator")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(themeManager.currentTheme.primary)

                Text("See the difference between protected and unprotected connections")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            // VPN Toggle Selector
            HStack(spacing: 0) {
                Button("Without VPN") {
                    withAnimation(.spring()) {
                        showWithVPN = false
                        resetSimulation()
                    }
                }
                .foregroundStyle(showWithVPN ? themeManager.currentTheme.primary : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(showWithVPN ? Color.clear : themeManager.currentTheme.dangerColor)

                Button("With VPN") {
                    withAnimation(.spring()) {
                        showWithVPN = true
                        resetSimulation()
                    }
                }
                .foregroundStyle(showWithVPN ? .white : themeManager.currentTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(showWithVPN ? themeManager.currentTheme.successColor : Color.clear)
            }
            .background(
                colorScheme == .dark ?
                Color(.systemGray5) :
                    Color(.systemGray6)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Traffic Simulation View

            TrafficSimulatorCanvas(
                showWithVPN: showWithVPN,
                isSimulating: $isSimulating,
                animatingPackets: $animatingPackets,
                interceptedData: $interceptedData,
                packetProgress: $packetProgress
            )
            .frame(height: 200)
            .padding()
            .themedBackground(0.1)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Control Button
            Button(isSimulating ? "Stop Simulation" : "Start Traffic Simulation") {
                if isSimulating {
                    stopSimulation()
                } else {
                    startSimulation()
                }
            }
            .buttonStyle(
                ThemedPrimaryButtonStyle(
                    color: isSimulating
                    ? themeManager.currentTheme.dangerColor
                    : themeManager.currentTheme.successColor
                )
            )

            // Intercepted Data Display
            if isSimulating || !interceptedData.isEmpty {
                InterceptedDataView(
                    data: interceptedData,
                    isEncrypted: showWithVPN
                )
            }

            // VPN Confirmation Buttons
            VStack(spacing: 12) {
                Text("Is your VPN currently active?")
                    .font(.headline)
                    .fontWeight(.medium)

                HStack(spacing: 16) {
                    Button("Yes, VPN Active") {
                        onSelection(true)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("No VPN") {
                        onSelection(false)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding(.top)
        }
    }

    private func startSimulation() {
        isSimulating = true
        interceptedData.removeAll()
        simulateTraffic()
    }

    private func stopSimulation() {
        isSimulating = false
        animatingPackets.removeAll()
    }

    private func resetSimulation() {
        stopSimulation()
        interceptedData.removeAll()
    }

    private func simulateTraffic() {
        guard isSimulating else { return }

        let sampleData = [
                    "Banking Login",
                    "Password: mypassword123",
                    "Account: 1234567890",
                    "Transfer: $500",
                    "Personal Message",
                    "Credit Card: 1234-5678-9012"
                ]

        let randomData = sampleData.randomElement() ?? "Data Packet"
        let packet = PacketAnimation(
            data: randomData,
            isEncrypted: showWithVPN
        )
        animatingPackets.append(packet)

        // Animate packet movement
        withAnimation(.linear(duration: 2.0)) {
            packetProgress[packet.id] = 1.0
        }

        // Simulate interception after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.isSimulating {
                let displayData = showWithVPN ? generateEncryptedString() : randomData

                self.interceptedData.append(displayData)

                // remove completed packet
                self.animatingPackets.removeAll { $0.id == packet.id }

                // schedule next packet
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.simulateTraffic()
                }
            }
        }
    }

    private func generateEncryptedString() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"
        return String((0..<12).compactMap { _ in chars.randomElement() })
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    VPNTrafficSimulatorView(
        detector: VPNStatusDetector(),
        onSelection: { _ in

        }
    )
    .environmentObject(mockThemeManager)
}
