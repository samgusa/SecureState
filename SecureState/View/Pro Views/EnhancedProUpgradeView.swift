//
//  EnhancedProUpgradeView.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI
import StoreKit

struct EnhancedProUpgradeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var storeManager: EnhancedStoreManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedTier: ProductTier = .oneTimePro

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    upgradeHeader

                    // product selector
                    productSelector

                    // selected product details
                    if let product = storeManager.product(for: selectedTier) {
                        ProductDetailsCard(
                            product: product,
                            tier: selectedTier,
                            isPurchased: storeManager.isPurchased(selectedTier)
                        )
                    }

                    // Purchase button
                    if let product = storeManager.product(for: selectedTier),
                       !storeManager.isPurchased(selectedTier) {
                        purchaseButton(for: product)
                    }

                    // restore button
                    restoreButton

                    if storeManager.hasActiveSubscription {
                        Button {
                            storeManager.showManageSubscriptions = true
                        } label: {
                            Text("Manage Subscription")
                                .font(.subheadline)
                                .foregroundStyle(themeManager.currentTheme.primary)
                        }
                    }

                    // feature comparison
                    featureComparison
                }
                .padding()
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("Done") { dismiss() }
                }
            }
            .manageSubscriptionsSheet(isPresented: $storeManager.showManageSubscriptions)
        }
    }

    private var upgradeHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [themeManager.currentTheme.warningColor, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white)
            }

            Text("Unlock Premium Features")
                .font(.title2)
                .fontWeight(.bold)

            Text("Choose the plan that's right for you")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var productSelector: some View {
        VStack(spacing: 12) {
            Text("Select Plan")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(ProductTier.allCases, id: \.rawValue) { tier in
                ProductTierButton(
                    tier: tier,
                    product: storeManager.product(for: tier),
                    isSelected: selectedTier == tier,
                    isPurchased: storeManager.isPurchased(tier)) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTier = tier
                        }
                        Haptic.tap()
                    }
            }
        }
    }

    private func purchaseButton(for product: Product) -> some View {
        Button {
            Task {
                await storeManager.purchase(product)
                // Dismiss sheet on successful purchase
                if storeManager.isPurchased(selectedTier) {
                    dismiss()
                }
            }
        } label: {
            HStack {
                if storeManager.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Purchase \(selectedTier.displayName)")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(product.displayPrice)
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [selectedTier.color, selectedTier.color.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(storeManager.isLoading)
    }

    private var restoreButton: some View {
        Button {
            Task {
                await storeManager.restorePurchases()
            }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(themeManager.currentTheme.primary)
        }
    }

    private var featureComparison: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's Included")
                .font(.headline)
                .fontWeight(.semibold)

            HStack {
                Text("Feature")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 24) {
                    Text("Pro")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(width: 60)

                    Text("Trends+")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(width: 60)
                }
            }
            .padding(.bottom, 8)

            VStack(spacing: 16) {
                // ONE-TIME PRO FEATURES
                FeatureComparisonRow(
                    feature: "Color Themes",
                    pro: true,
                    trendsPlus: true
                )

                FeatureComparisonRow(
                    feature: "Achievements System",
                    pro: true,
                    trendsPlus: true
                )

                FeatureComparisonRow(
                    feature: "Badge Display",
                    pro: true,
                    trendsPlus: true
                )

                Rectangle()
                    .fill(themeManager.currentTheme.primary.opacity(0.15))
                    .frame(height: 1)

                // SUBSCRIPTION-ONLY FEATURES
                FeatureComparisonRow(
                    feature: "Global Security Trends",
                    pro: false,
                    trendsPlus: true
                )

                FeatureComparisonRow(
                    feature: "Real-time CVE Tracking",
                    pro: false,
                    trendsPlus: true
                )

                FeatureComparisonRow(
                    feature: "90-Day Trend History",
                    pro: false,
                    trendsPlus: true
                )
            }
        }
        .padding()
        .themedBackground(0.1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    EnhancedProUpgradeView(storeManager: EnhancedStoreManager())
        .environmentObject(mockThemeManager)
}
