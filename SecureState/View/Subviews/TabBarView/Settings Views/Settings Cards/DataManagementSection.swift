//
//  DataManagementSection.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/8/25.
//

import SwiftUI

struct DataManagementSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var showClearDataConfirmation: Bool

    var body: some View {
        VStack(spacing: 8) {
            Button {
                withAnimation((.easeInOut(duration: 0.8))) {
                    showClearDataConfirmation = true
                }
            } label: {
                SettingsRow(
                    icon: "trash.fill",
                    title: "Clear All Data",
                    subtitle: "Remove saved assessments",
                    color: themeManager.currentTheme.dangerColor
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    DataManagementSection(showClearDataConfirmation: .constant(false))
        .environmentObject(mockThemeManager)
}
