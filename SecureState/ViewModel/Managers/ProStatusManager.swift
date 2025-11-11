//
//  ProStatusManager.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import Combine

// MARK: - Pro Status Manager
@MainActor
class ProStatusManager: ObservableObject {
    @Published var isPro: Bool = false
    @Published var hasTrendsAccess: Bool = false

#if DEBUG
    private var isDebugMode: Bool = false
#endif

    private var storeManager: EnhancedStoreManager
    private var cancellables = Set<AnyCancellable>()

    init(storeManager: EnhancedStoreManager) {
        self.storeManager = storeManager
        updateAccessLevel()
        self.isPro = UserDefaults.standard.bool(forKey: "isProUser")

        storeManager.$activeSubscriptions
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateAccessLevel()
            }
            .store(in: &cancellables)
    }

    convenience init(storeManager: EnhancedStoreManager, debug: Bool = false) {
        self.init(storeManager: storeManager)

#if DEBUG
        if debug || UserDefaults.standard.bool(forKey: "debugProEnabled") {
            self.isDebugMode = true
            self.isPro = true
            self.hasTrendsAccess = true
        }
#endif
    }

    private func updateAccessLevel() {
#if DEBUG
        guard !isDebugMode else { return }
#endif
        isPro = storeManager.hasProAccess
        hasTrendsAccess = storeManager.hasTrendAccess
    }

    func showUpgradeSheet() -> EnhancedProUpgradeView {
        EnhancedProUpgradeView(storeManager: storeManager)
    }

    func unlockPro() {
        isPro = true
    }

    func resetPro() {
        isPro = false
    }
}

#if DEBUG
extension ProStatusManager {
    // Enable pro features for testing (debug only)
    func enableDebugPro() {
        self.isPro = true
        self.hasTrendsAccess = true
        UserDefaults.standard.set(true, forKey: "debugProEnabled")
    }

    // Diable debug pro features
    func disableDebugPro() {
        self.isPro = false
        self.hasTrendsAccess = false
        UserDefaults.standard.removeObject(forKey: "debugProEnabled")
    }

    // Check if debud Pro is enabled
    var isDebugProEnabled: Bool {
        UserDefaults.standard.bool(forKey: "debugProEnabled")
    }
}
#endif
