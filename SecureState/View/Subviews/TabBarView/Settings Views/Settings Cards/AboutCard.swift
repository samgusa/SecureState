//
//  AboutCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/8/25.
//

import SwiftUI

struct AboutCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showAbout: Bool = false

    var body: some View {
        Button {
            showAbout = true
        } label: {
            SettingsRow(
                icon: "info.circle.fill",
                title: "About SecureState",
                subtitle: "Version 1.0",
                color: themeManager.currentTheme.accent
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    AboutCard()
        .environmentObject(mockThemeManager)

}
