//
//  TipCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct TipCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let tip: SecurityTip
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                if let category = tip.category {
                    ZStack {
                        Circle()
                            .fill(category.color.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: category.icon)
                            .foregroundStyle(category.color)
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 40, height: 40)

                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.gray)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(tip.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(themeManager.currentTheme.primary)
                    }

                    if let category = tip.category {
                        Text(category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if isExpanded {
                Rectangle()
                    .fill(themeManager.currentTheme.primary.opacity(0.15))
                    .frame(height: 1)

                Text(tip.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .cardStyle(tip.category?.color ?? Color.gray)
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    TipCard(
        tip: .init(
            id: "001",
            title: "Use a Password Manager with Zero-Knowledge Architecture",
            description: "Choose password managers that use zero-knowledge encryption. This means even the company cannot access your passwords - only you hold the master key. Avoid storing passwords in browsers or unencrypted notes.",
            category: .passwords
        )
    )
    .environmentObject(mockThemeManager)
}
