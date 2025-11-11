//
//  InterceptedDataView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct InterceptedDataView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let data: [String]
    let isEncrypted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isEncrypted ? "lock.fill" : "lock.open.fill")
                    .foregroundStyle(isEncrypted ? themeManager.currentTheme.successColor : themeManager.currentTheme.dangerColor)
                Text("Network Observer Sees:")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(data.suffix(5).enumerated()), id: \.offset) { index, item in
                        Text(item)
                            .font(.caption)
                            .monospaced()
                            .foregroundStyle(isEncrypted ? themeManager.currentTheme.successColor : themeManager.currentTheme.dangerColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(isEncrypted ? themeManager.currentTheme.successColor.opacity(0.1) : themeManager.currentTheme.dangerColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            .frame(maxHeight: 100)
        }
        .padding()
        .cardStyle(isEncrypted ? themeManager.currentTheme.successColor : themeManager.currentTheme.dangerColor)
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    InterceptedDataView(
        data: [
            "Testing 1",
            "Testing 2",
            "Testing 3",
            "Testing 4",
            "Testing 5",
            "Testing 6"
        ],
        isEncrypted: true
    )
        .environmentObject(mockThemeManager)
}
