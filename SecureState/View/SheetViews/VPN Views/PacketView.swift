//
//  PacketView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct PacketView: View {
    let packet: VPNTrafficSimulatorView.PacketAnimation

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "envelope.fill")
                .font(.caption)
            Text(packet.isEncrypted ? "###" : packet.data.prefix(8))
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(packet.isEncrypted ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        }
    }
}

#Preview {
    PacketView(packet: VPNTrafficSimulatorView.PacketAnimation(
        data: "Password",
        isEncrypted: false,
        progress: 0.0
    )
    )
}
