//
//  FeatureComparisonRow.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct FeatureComparisonRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let feature: String
    let pro: Bool
    let trendsPlus: Bool

    var body: some View {
        HStack {
            Text(feature)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 24) {
                Image(systemName: pro ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(pro ? themeManager.currentTheme.successColor : .gray)
                    .frame(width: 60)

                Image(systemName: trendsPlus ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(trendsPlus ? themeManager.currentTheme.successColor : .gray)
                    .frame(width: 60)
            }
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    FeatureComparisonRow(
        feature: "Color Themes",
        pro: true,
        trendsPlus: true
    )
    .environmentObject(mockThemeManager)

    FeatureComparisonRow(
        feature: "Achievements System",
        pro: true,
        trendsPlus: true
    )
    .environmentObject(mockThemeManager)

    FeatureComparisonRow(
        feature: "Badge Display",
        pro: true,
        trendsPlus: true
    )
    .environmentObject(mockThemeManager)
}
