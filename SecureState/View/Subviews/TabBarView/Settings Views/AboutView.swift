//
//  AboutView.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/8/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    private let principles: [(title: String, description: String, icon: String, color: Color)] = [
        ("Privacy First", "No tracking, no analytics, no third-party SDKs", "lock.shield.fill", .blue),
        ("Honest Assessment", "Real security scoring, not security theater", "checkmark.seal.fill", .green),
        ("Educational", "Help you understand why security matters", "graduationcap.fill", .yellow),
        ("Transparent", "Open about limitations and detection methods", "eye.fill", .purple)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // App Icon & Info
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 48))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

                        Text("Secure State")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)

                    // Mission Statement
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Our Mission")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .themedForeground(themeManager.currentTheme.primary)

                        Text("SecureState provides real-time, contextual security awareness through honest assessment and education. We believe in empowering users to make informed decisions about their digital security - without fear-mongering or data collection. Pro users can access global security trends from public sources.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .themedBackground(0.1)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // Core Principles
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Core Principles")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .themedForeground(themeManager.currentTheme.primary)

                        ForEach(principles, id: \.title) { principle in
                            principleRow(
                                title: principle.title,
                                description: principle.description,
                                icon: principle.icon,
                                color: principle.color
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .themedBackground(0.1)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // Credits
                    VStack(spacing: 8) {
                        Text("Made for privacy-conscious users")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("© 2025 SecureState")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    func principleRow(title: String, description: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    AboutView()
        .environmentObject(mockThemeManager)
}
