//
//  PacketView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct PacketView: View {
    @EnvironmentObject var themeManager: ThemeManager
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
        .background(packet.isEncrypted ? themeManager.currentTheme.successColor.opacity(0.3) : themeManager.currentTheme.dangerColor.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.primary.opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    PacketView(packet: VPNTrafficSimulatorView.PacketAnimation(
        data: "Password",
        isEncrypted: false,
        progress: 0.0
    )
    )
    .environmentObject(mockThemeManager)
}
