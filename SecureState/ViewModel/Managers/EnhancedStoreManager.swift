//
//  EnhancedStoreManager.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import StoreKit

@MainActor
class EnhancedStoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIds: Set<String> = []
    @Published var activeSubscriptions: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var purchaseError: String?
    @Published var showManageSubscriptions: Bool = false

    private var updateListenerTask: Task<Void, Error>?

    var hasProAccess: Bool {
        purchasedProductIds.contains(ProductTier.oneTimePro.rawValue) ||
        !activeSubscriptions.isEmpty
    }

    var hasTrendAccess: Bool {
        activeSubscriptions.contains(ProductTier.monthlyTrendsPlus.rawValue) ||
        activeSubscriptions.contains(ProductTier.yearlyTrendsPlus.rawValue)
    }

    // Add helper to check if user has any active subscriptions
    var hasActiveSubscription: Bool {
        !activeSubscriptions.isEmpty
    }

    init() {
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // Product loading
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let productsIDs = ProductTier.allCases.map { $0.rawValue }
            let products = try await Product.products(for: productsIDs)
            self.products = products.sorted { p1, p2 in
                // Sort one time first, then yearly, then monthly
                if p1.id == ProductTier.oneTimePro.rawValue { return true }
                if p2.id == ProductTier.oneTimePro.rawValue { return false }
                if p1.id == ProductTier.yearlyTrendsPlus.rawValue { return true }
                return false
            }
        } catch {
            purchaseError = "Could not load products"
        }
    }

    func purchase(_ product: Product) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transation = try checkVerified(verification)
                await transation.finish()
                await updatePurchasedProducts()

            case .userCancelled:
                break

            case .pending:
                purchaseError = "Purchase pending approval"

            @unknown default:
                break
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
        }
    }

    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        var subscriptions: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .nonConsumable {
                    purchased.insert(transaction.productID)
                } else if transaction.productType == .autoRenewable {
                    subscriptions.insert(transaction.productID)
                }
            }
        }
        purchasedProductIds = purchased
        activeSubscriptions = subscriptions
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    func product(for tier: ProductTier) -> Product? {
        products.first { $0.id == tier.rawValue }
    }

    func isPurchased(_ tier: ProductTier) -> Bool {
        if tier == .oneTimePro {
            return purchasedProductIds.contains(tier.rawValue)
        } else {
            return activeSubscriptions.contains(tier.rawValue)
        }
    }

    func getSubscriptionInfo() -> String? {
        if activeSubscriptions.contains(ProductTier.monthlyTrendsPlus.rawValue) {
            return "Trends Plus (Monthly) - Active"
        } else if activeSubscriptions.contains(ProductTier.yearlyTrendsPlus.rawValue) {
            return "Trends Plus (Yearly) - Active"
        }
        return nil
    }
}
