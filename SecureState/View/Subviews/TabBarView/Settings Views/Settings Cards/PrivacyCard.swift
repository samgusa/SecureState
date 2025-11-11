//
//  PrivacyCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/8/25.
//

import SwiftUI

struct PrivacyCard: View {
    @State private var showPrivacy = false

    var body: some View {
        Button {
            showPrivacy = true
        } label: {
            SettingsRow(
                icon: "hand.raised.fill",
                title: "Privacy & Transparency",
                subtitle: "How we protect your data",
                color: .purple
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    PrivacyCard()
        .environmentObject(mockThemeManager)
}
