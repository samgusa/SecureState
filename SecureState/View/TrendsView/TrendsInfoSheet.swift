//
//  TrendsInfoSheet.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct TrendsInfoSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About Global Security Trends")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Track worldwide cybersecurity activity with real-time data from trusted sources.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Privacy Section
                    InfoSection(
                        icon: "lock.shield.fill",
                        title: "100% Privacy-Safe",
                        color: themeManager.currentTheme.successColor,
                        points: [
                            "No personal data collected or transmitted",
                            "No user tracking or analytics",
                            "All data cached locally on your device",
                            "Public data sources only"
                        ]
                    )

                    // Data Sources
                    InfoSection(
                        icon: "network",
                        title: "Data Sources",
                        color: themeManager.currentTheme.primary,
                        points: [
                            "National Vulnerability Database (NVD) - CVE vulnerabilities",
                            "Official public cybersecurity data source",
                            "Data updated once every 24 hours"
                        ]
                    )

                    // Security
                    InfoSection(
                        icon: "checkmark.shield.fill",
                        title: "Security Measures",
                        color: .purple,
                        points: [
                            "HTTPS-only connections",
                            "API keys stored securely",
                            "Strict JSON validation",
                            "Rate limiting (24-hour cooldown)"
                        ]
                    )

                    // Educational Purpose
                    InfoSection(
                        icon: "graduationcap.fill",
                        title: "Educational Purpose",
                        color: themeManager.currentTheme.warningColor,
                        points: [
                            "Understand global threat landscape",
                            "Stay informed about security trends",
                            "Make better security decisions",
                            "No fear-mongering - just facts"
                        ]
                    )
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    TrendsInfoSheet()
        .environmentObject(mockThemeManager)
}
