//
//  SimpleCVECard.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct SimpleCVECard: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    let cve: SimpleCVE
    @State private var isExpanded: Bool = false

    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }){
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        // Serverity Badge
                        HStack(spacing: 6) {
                            Text(cve.severity == .unknown ? "Pending" : cve.severity.displayName)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(severityColor.contrastingTextColor())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(severityColor)
                                .clipShape(Capsule())

                            Text(cve.displayDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Vulnerability TYPE:
                        Text(cve.userFriendlyType)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .themedForeground(themeManager.currentTheme.primary)

                        // CVE ID
                        Text(cve.id)
                            .font(.caption)
                            .foregroundStyle(.secondary)
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

                    VStack(alignment: .leading, spacing: 12) {
                        // Description
                        VStack(alignment: .leading, spacing: 4) {
                            Text("What is it?")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Text(cve.description)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Affected products if available
                        if !cve.affectedProducts.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Affects")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                ForEach(cve.affectedProducts.prefix(3), id: \.self) { product in
                                    HStack(spacing: 4) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 4))
                                            .foregroundStyle(.secondary)
                                        Text(product)
                                            .font(.caption)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .themedBackground(0.1, 0.2)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var severityColor: Color {
        cve.severity.displayColor(for: colorScheme)
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    SimpleCVECard(
        cve: SimpleCVE(
            id: "001",
            severity: .critical,
            published: Date(),
            description: "This is the description",
            weaknessType: "vulnerability",
            affectedProducts: [""]
        )
    )
    .environmentObject(mockThemeManager)
}
