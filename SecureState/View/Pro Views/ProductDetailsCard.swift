//
//  ProductDetailsCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI
import StoreKit

struct ProductDetailsCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let product: Product
    let tier: ProductTier
    let isPurchased: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(tier.displayName)
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                if isPurchased {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .themedForeground(themeManager.currentTheme.successColor)
                        Text("Purchased")
                            .font(.caption)
                            .fontWeight(.medium)
                            .themedForeground(themeManager.currentTheme.successColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeManager.currentTheme.successColor.opacity(0.1))
                    .clipShape(Capsule())
                } else {
                    Text(product.displayPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(tier.color)
                }
            }

            Text(tier.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Rectangle()
                .fill(themeManager.currentTheme.primary.opacity(0.15))
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(tier.features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(tier.color)
                            .font(.caption)

                        Text(feature)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .cardStyle(tier.color)
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    ProductDetailsCard(
        product: Product.mock,
        tier: .oneTimePro,
        isPurchased: false
    )
        .environmentObject(mockThemeManager)
}
