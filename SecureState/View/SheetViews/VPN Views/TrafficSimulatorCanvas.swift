//
//  TrafficSimulatorCanvas.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct TrafficSimulatorCanvas: View {
    let showWithVPN: Bool
    @Binding var isSimulating: Bool
    @Binding var animatingPackets: [VPNTrafficSimulatorView.PacketAnimation]
    @Binding var interceptedData: [String]


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Connecting Line
                Path { path in
                    let startPoint = CGPoint(x: 50, y: geometry.size.height / 2)
                    let endPoint = CGPoint(x: geometry.size.width - 50, y: geometry.size.height / 2)
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                }
                .stroke(showWithVPN ? Color.green : Color.red, lineWidth: 3)
                .opacity(0.6)

                // Device Icon (Left)

                VStack {
                    Image(systemName: "iphone")
                        .font(.title)
                        .foregroundStyle(.blue)
                    Text("Your Device")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .position(x: 50, y: geometry.size.height / 2)

                // Server Icon (Right)
                VStack {
                    Image(systemName: "server.rack")
                        .font(.title)
                        .foregroundStyle(.blue)
                    Text("Server")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .position(x: geometry.size.width - 50, y: geometry.size.height / 2)

                // Network Observer (Middle)
                VStack {
                    Image(systemName: showWithVPN ? "eye.slash.fill" : "eye.fill")
                        .font(.title2)
                        .foregroundStyle(showWithVPN ? .green : .red)
                    Text(showWithVPN ? "Can't See" : "Intercepting")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(showWithVPN ? .green : .red)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 40)

                // Animated Packets
                ForEach(animatingPackets) { packet in
                    PacketView(packet: packet)
                        .position(x: 50 + (geometry.size.width - 100) * packet.progress,
                                  y: geometry.size.height / 2)

                }
            }
        }
    }
}

#Preview {
    TrafficSimulatorCanvas(
        showWithVPN: false,
        isSimulating: .constant(true),
        animatingPackets: .constant(
            [VPNTrafficSimulatorView.PacketAnimation(
                data: "Username",
                isEncrypted: false,
                progress: 0.0
            ),
             VPNTrafficSimulatorView.PacketAnimation(
                data: "Password",
                isEncrypted: false,
                progress: 0.0
             ),
             VPNTrafficSimulatorView.PacketAnimation(
                 data: "Data",
                 isEncrypted: false,
                 progress: 0.0
             )
            ]),
        interceptedData: .constant(["Info", "Data", "Password"])
    )
}
