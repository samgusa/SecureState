//
//  PersistenceController.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//

import Foundation
import SwiftData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    private init() {
        container = try! ModelContainer(for: StoredComponent.self, RememberedNetwork.self, RememberedLocation.self, StoredTrendData.self, UnlockedAchievement.self)
    }
}
