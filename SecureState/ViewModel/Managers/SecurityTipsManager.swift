//
//  SecurityTipsManager.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation

// Tips Manager
class SecurityTipsManager: ObservableObject {
    @Published var allTips: [SecurityTip] = []

    init() {
        loadTips()
    }

    private func loadTips() {
        if let tips: [SecurityTip] = Bundle.main.decode([SecurityTip].self, from: "Tips.json") {
            allTips = tips
        } else {
            allTips = []
        }
    }

    func getTipOfTheDay()-> SecurityTip? {
        guard !allTips.isEmpty else { return nil }
        // create deterministic but daily-changing seed
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let daysSinceEpoch = calendar.date(from: components)?.timeIntervalSince1970 ?? 0
        let seed = Int(daysSinceEpoch / 86400)

        let index = abs(seed) % allTips.count
        return allTips[index]
    }
}
