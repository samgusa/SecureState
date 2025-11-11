//
//  EducationRow.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct EducationRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(themeManager.currentTheme.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    EducationRow(
        icon: "shield.slash.fill",
        title: "CVE (Common Vulnerabilities and Exposures)",
        description: "Publicly disclosed security flaws in software that could be exploited by attackers."
    )
    .environmentObject(mockThemeManager)
}
