//
//  SecurityTipsView.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct SecurityTipsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var tipsManager = SecurityTipsManager()

    @State private var searchText: String = ""
    @State private var showAllTips: Bool = false

    var filteredTips: [SecurityTip] {
        if searchText.isEmpty {
            return tipsManager.allTips
        }

        return tipsManager.allTips.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var tipOfTheDay: SecurityTip? {
        tipsManager.getTipOfTheDay()
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            headerSection

            if let todaysTip = tipOfTheDay {
                tipOfTheDayCard(tip: todaysTip)
            }

            // Browse all tips toggle
            browseAllTipsButton

            // AllTips (if expanded)
            if showAllTips {
                allTipsSection
            }

        }
        .padding()
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Security Tips")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(themeManager.currentTheme.primary)

                    Text("Practical advice for everyday digital security")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack {
                Label("\(tipsManager.allTips.count) Tips", systemImage: "shield.fill")
                    .font(.caption)
                    .foregroundStyle(themeManager.currentTheme.accent)

                Spacer()

            }
        }
        .padding()
        .themedBackground(0.1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func tipOfTheDayCard(tip: SecurityTip) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(themeManager.currentTheme.warningColor)

                Text("Tip of the Day")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(themeManager.currentTheme.primary)

                Spacer()
            }

            // Category Badge (if available)
            if let category = tip.category {
                HStack(spacing: 6) {
                    Image(systemName: category.icon)
                        .font(.caption2)
                    Text(category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(category.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(category.color.opacity(0.15))
                .clipShape(Capsule())
            }

            // Title
            Text(tip.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(themeManager.currentTheme.primary)

            // Description
            Text(tip.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [themeManager.currentTheme.warningColor.opacity(0.1), .yellow.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [themeManager.currentTheme.warningColor.opacity(0.3), .yellow.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
        .shadow(color: themeManager.currentTheme.warningColor.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var browseAllTipsButton: some View {
        Button {
            withAnimation(.spring()) {
                showAllTips.toggle()
            }
        } label: {
            HStack {
                Image(systemName: showAllTips ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .font(.title3)

                Text(showAllTips ? "Hide All Tips" : "Browse All Tips")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(filteredTips.count)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(themeManager.currentTheme.primary)
            .padding()
            .background(
                themeManager.currentTheme.accent.opacity(
                    colorScheme == .dark ? 0.25 : 0.1
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        themeManager.currentTheme.primary.opacity(
                            colorScheme == .dark ? 0.5 : 0.2
                        ),
                        lineWidth: 1.5
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var allTipsSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredTips.filter { $0.id != tipOfTheDay?.id }) { tip in
                TipCard(tip: tip)
            }

            if filteredTips.isEmpty {
                emptyState
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No tips found")
                .font(.headline)

            Text("Try adjusting your search or category filter")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    SecurityTipsView()
        .environmentObject(mockThemeManager)
}
