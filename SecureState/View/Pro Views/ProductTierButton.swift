//
//  ProductTierButton.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI
import StoreKit

struct ProductTierButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    let tier: ProductTier
    let product: Product?
    let isSelected: Bool
    let isPurchased: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12){
                HStack(spacing: 16) {
                    // ICON
                    ZStack {
                        Circle()
                            .fill(tier.color.opacity(0.15))
                            .frame(width: 50, height: 50)

                        Image(systemName: tier.icon)
                            .font(.title3)
                            .foregroundStyle(tier.color)
                    }
                    // Name and Price
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(tier.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)

                            if isPurchased {
                                Image(systemName: "checkmark.circle.fill")
                                    .themedForeground(themeManager.currentTheme.successColor)
                                    .font(.subheadline)
                            }
                        }

                        // PRICE
                        if let product = product {
                            HStack(spacing: 4) {
                                Text(product.displayPrice)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(tier.color)

                                if tier == .monthlyTrendsPlus {
                                    Text("/ month")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                } else if tier == .yearlyTrendsPlus {
                                    Text("/ year")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } else {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Loading price...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(tier.color)
                    } else {
                        Image(systemName: "circle")
                            .font(.title2)
                            .foregroundStyle(.secondary.opacity(0.3))
                    }
                }
            }
            .padding()
            .background(
                Group {
                    if isSelected {
                        tier.color.opacity(0.1)
                    } else {
                        Color(.systemBackground)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? tier.color : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    ProductTierButton(
        tier: .monthlyTrendsPlus,
        product: nil,
        isSelected: false,
        isPurchased: false,
        action: {
        }
    )
    .environmentObject(mockThemeManager)
}
