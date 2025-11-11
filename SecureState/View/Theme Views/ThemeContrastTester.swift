//
//  ThemeContrastTester.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct ThemeContrastTester: View {
    var theme: AppColorTheme
    @Environment(\.colorScheme) var scheme

    var body: some View {
        VStack(spacing: 12) {
            Text(theme.displayName)
                .font(.headline)
                .foregroundStyle(theme.primary)
            HStack(spacing: 8) {
                Circle().fill(theme.successColor).frame(width: 24, height: 24)
                Circle().fill(theme.warningColor).frame(width: 24, height: 24)
                Circle().fill(theme.dangerColor).frame(width: 24, height: 24)
                Circle().fill(theme.infoColor).frame(width: 24, height: 24)
            }
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.previewGradient)
                .frame(height: 50)
                .overlay(
                    Text(scheme == .dark ? "Dark" : "Light")
                        .font(.caption)
                )
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ThemeContrastTester(theme: .default)
}
