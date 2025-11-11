//
//  AppleReleaseCycleInfo.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct AppleReleaseCycleInfo: View {
    @EnvironmentObject var themeManager: ThemeManager

    let releaseInfo = [
        ("Major iOS Release", "September annually", "iOS 18, 26, etc."),
        ("Security Updates", "Throughout the year", "Critical patches"),
        ("Point Releases", "Every few weeks", "Bug fixes, features")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(themeManager.currentTheme.primary)

                Text("Apple's Update Schedule")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            VStack(alignment: .leading, spacing: 8) {
                ForEach(releaseInfo, id: \.0) { info in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .foregroundStyle(themeManager.currentTheme.primary)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                            .padding(.leading, 8)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(info.0)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            HStack {
                                Text(info.1)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("•")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(info.2)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .themedBackground(0.1)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.primary.opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    AppleReleaseCycleInfo()
        .environmentObject(mockThemeManager)
}
