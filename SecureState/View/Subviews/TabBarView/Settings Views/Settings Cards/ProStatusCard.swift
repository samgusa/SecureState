//
//  ProStatusCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/8/25.
//

import SwiftUI
import StoreKit

struct ProStatusCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var proManager: ProStatusManager
    @EnvironmentObject var storeManager: EnhancedStoreManager
    @State private var showProView: Bool = false
    @State private var showManageSubscriptions: Bool = false


    var body: some View {
        Group {
            if proManager.isPro {
                // Pro Active
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(themeManager.currentTheme.successColor.opacity(0.15))
                            .frame(width: 45, height: 45)

                        Image(systemName: "checkmark.seal.fill")
                            .themedForeground(themeManager.currentTheme.successColor)
                            .font(.title3)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SecureState Pro")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .themedForeground(themeManager.currentTheme.primary)

                        Text("All features unlocked")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(themeManager.currentTheme.successColor.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.currentTheme.successColor, lineWidth: 1)
                }
                // Subscription Management (only if active subscription)
                if storeManager.hasActiveSubscription {
                    Button {
                        showManageSubscriptions = true
                    } label: {
                        SettingsRow(
                            icon: "creditcard.fill",
                            title: "Manage Subscription",
                            subtitle: storeManager.getSubscriptionInfo() ?? "Active",
                            color: themeManager.currentTheme.primary
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                // Upgrade available
                Button {
                    showProView = true
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [themeManager.currentTheme.warningColor, .yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)

                            Image(systemName: "star.fill")
                                .foregroundStyle(.white)
                                .font(.title3)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to Pro")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)

                            Text("Support this project by upgrading")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Starts at only $0.99")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .themedForeground(themeManager.currentTheme.warningColor)

                            Text("One-time or subscription")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [themeManager.currentTheme.warningColor.opacity(0.1), .yellow.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [themeManager.currentTheme.warningColor.opacity(0.3), .yellow.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showProView) {
            EnhancedProUpgradeView(storeManager: storeManager)
        }
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
    }
}


#Preview("Free User") {
    // We wrap setup code in a closure that returns the view.
    let view: some View = {
        let mockThemeManager = ThemeManager()
        let mockStoreManager = EnhancedStoreManager()
        let freeProManager = ProStatusManager(storeManager: mockStoreManager)
        freeProManager.isPro = false  // not pro

        return ProStatusCard()
            .environmentObject(mockThemeManager)
            .environmentObject(freeProManager)
            .environmentObject(mockStoreManager)
    }()
    return view
}

#Preview("Pro User") {
    let view: some View = {
        let mockThemeManager = ThemeManager()
        let mockStoreManager = EnhancedStoreManager()
        let proManager = ProStatusManager(storeManager: mockStoreManager, debug: true)

        return ProStatusCard()
            .environmentObject(mockThemeManager)
            .environmentObject(proManager)
            .environmentObject(mockStoreManager)
    }()
    return view
}
