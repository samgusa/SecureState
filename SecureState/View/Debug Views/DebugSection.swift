//
//  DebugSection.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/8/25.
//

import SwiftUI
import SwiftData

#if DEBUG
struct DebugSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var proManager: ProStatusManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Debug Settings")
                .font(.headline)
                .fontWeight(.semibold)
                .themedForeground(themeManager.currentTheme.dangerColor)

            VStack(spacing: 12) {
                Button {
                    if proManager.isDebugProEnabled {
                        proManager.disableDebugPro()
                    } else {
                        proManager.enableDebugPro()
                    }
                } label: {
                    SettingsRow(
                        icon: proManager.isDebugProEnabled ? "checkmark.circle.fill" : "xmark.circle.fill",
                        title: "Debug Pro Mode",
                        subtitle: proManager.isDebugProEnabled ? "Enabled" : "Disabled",
                        color: proManager.isDebugProEnabled ? themeManager.currentTheme.successColor : themeManager.currentTheme.dangerColor
                    )
                }
                .buttonStyle(PlainButtonStyle())

                if proManager.isDebugProEnabled {
                    HStack {
                        Image(systemName: "info.circle")
                            .themedForeground(themeManager.currentTheme.warningColor)
                        Text("Debug Pro is active. All premium features unlocked for testing.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(themeManager.currentTheme.warningColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

#endif

#Preview("Free User") {
    // We wrap setup code in a closure that returns the view.
    let mockThemeManager = ThemeManager()

    let view: some View = {
        let mockStoreManager = EnhancedStoreManager()
        let freeProManager = ProStatusManager(storeManager: mockStoreManager)
        freeProManager.isPro = false  // not pro

        return DebugSection()
            .environmentObject(mockThemeManager)
            .environmentObject(freeProManager)
            .environmentObject(mockStoreManager)
    }()
    return view
}

