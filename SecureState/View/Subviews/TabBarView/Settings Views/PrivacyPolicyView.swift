//
//  PrivacyPolicyView.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/8/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    var privacySections: [(title: String, icon: String, color: Color, points: [String])] {    [
        (
            title: "What We Don't Collect",
            icon: "xmark.circle.fill",
            color: themeManager.currentTheme.primary,
            points: [
                "No personal information",
                "No usage analytics",
                "No crash reporting",
                "No advertising identifiers",
                "No location data stored remotely",
                "No network activity logs"
            ]
        ),
        (
            title: "What Stays on Your Device",
            icon: "iphone.circle.fill",
            color: themeManager.currentTheme.primary,
            points: [
                "Security component scores",
                "User confirmations (VPN, iOS version, etc.)",
                "Remembered networks (hashed SSIDs only)",
                "Remembered locations (coarse geohashes)",
                "Security trend history (Pro feature only)"
            ]
        ),
        (
            title: "Network Requests",
            icon: "network",
            color: themeManager.currentTheme.warningColor,
            points: [
                "Pro users: Security trends from NIST NVD (public API)",
                "HTTPS-only connections",
                "No authentication required",
                "No user identification",
                "Cached locally for offline use"
            ]
        ),
        (
            title: "Transparency Commitments",
            icon: "eye.fill",
            color: Color.purple,
            points: [
                "No hidden backend servers",
                "No third-party SDKs",
                "Clear about detection limitations",
                "All data processing happens on-device",
                "No ADs"
            ]
        )
    ] }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.15))
                                .frame(width: 80, height: 80)

                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.purple)
                        }

                        Text("Privacy & Transparency")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Your security is our priority. Here's exactly what we do (and don't do) with your data.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)

                    // Privacy Sections
                    ForEach(privacySections, id: \.title) { section in
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: section.icon)
                                    .foregroundStyle(section.color)
                                    .font(.title2)

                                Text(section.title)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(section.points, id: \.self) { point in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(section.color)
                                            .font(.caption)
                                            .frame(width: 16)

                                        Text(point)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(section.color.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.currentTheme.primary.opacity(0.2), lineWidth: 1)
                        }
                        .padding(.horizontal)
                    }
                    // Bottom Statement
                    VStack(spacing: 12) {
                        Text("Questions or Concerns?")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text("SecureState is designed to be transparent. If you have questions about how anything works, add a review.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .themedBackground(0.1)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
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
}

#Preview {
    let mockThemeManager = ThemeManager()

    PrivacyPolicyView()
        .environmentObject(mockThemeManager)
}
