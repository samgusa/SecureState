//
//  TrafficSimulatorCanvas.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct TrafficSimulatorCanvas: View {
    @EnvironmentObject var themeManager: ThemeManager
    let showWithVPN: Bool
    @Binding var isSimulating: Bool
    @Binding var animatingPackets: [VPNTrafficSimulatorView.PacketAnimation]
    @Binding var interceptedData: [String]
    // UPDATE
    @Binding var packetProgress: [UUID: Double]


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Connection Line
                Path { path in
                    let startPoint = CGPoint(x: 50, y: geometry.size.height / 2)
                    let endPoint = CGPoint(x: geometry.size.width - 50, y: geometry.size.height / 2)
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                }
                .stroke(showWithVPN ? themeManager.currentTheme.successColor : themeManager.currentTheme.dangerColor, lineWidth: 3)
                .opacity(0.6)

                // Device Icon (Left)

                VStack {
                    Image(systemName: "iphone")
                        .font(.title)
                        .foregroundStyle(themeManager.currentTheme.primary)
                    Text("Your Device")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .position(x: 50, y: geometry.size.height / 2)

                // Server Icon (Right)
                VStack {
                    Image(systemName: "server.rack")
                        .font(.title)
                        .foregroundStyle(themeManager.currentTheme.primary)
                    Text("Server")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .position(x: geometry.size.width - 50, y: geometry.size.height / 2)

                // Network Observer (Middle)

                VStack {
                    Image(systemName: showWithVPN ? "eye.slash.fill" : "eye.fill")
                        .font(.title2)
                        .foregroundStyle(showWithVPN ? themeManager.currentTheme.successColor : themeManager.currentTheme.dangerColor)
                    Text(showWithVPN ? "Can't See" : "Intercepting")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(showWithVPN ? themeManager.currentTheme.successColor : themeManager.currentTheme.dangerColor)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 40)

                // Animated Packets
                ForEach(animatingPackets) { packet in
                    PacketView(packet: packet)
                        .position(x: 50 + (geometry.size.width - 100) * (packetProgress[packet.id] ?? 0.0),
                                  y: geometry.size.height / 2
                        )
                }
            }
        }
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
