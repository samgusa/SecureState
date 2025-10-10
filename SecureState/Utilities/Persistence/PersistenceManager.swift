//
//  PersistenceManager.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//

import Foundation
import SwiftData

class PersistenceManager {
    static func saveComponentState(
        identifier: ComponentIdentifier,
        autoScore: Int,
        userScore: Int,
        userConfirmed: Bool?,
        maxScore: Int,
        metadataJSON: String? = nil,
        context: ModelContext
    ) {
        guard shouldPersist(identifier) else { return }

        let id = identifier.rawValue
        let descriptor = FetchDescriptor<StoredComponent>(
            predicate: #Predicate { $0.identifier == id }
        )

        if let existing = try? context.fetch(descriptor).first {
            existing.autoScore = autoScore
            existing.userScore = userScore
            existing.userConfimed = userConfirmed
            existing.metadataJSON = metadataJSON
            existing.lastUpdated = Date()
            try? context.save()
        } else {
            let newComponent = StoredComponent(
                identifier: identifier.rawValue,
                autoScore: autoScore,
                userScore: userScore,
                userConfimed: userConfirmed,
                maxScore: maxScore,
                metadataJSON: metadataJSON
            )
            context.insert(newComponent)
            try? context.save()
        }

        DataStore.upsertComponent(
            identifier: identifier,
            autoScore: autoScore,
            userScore: userScore,
            userConfirmed: userConfirmed,
            maxScore: maxScore,
            context: context
        )
     }

    static func shouldPersist(_ identifier: ComponentIdentifier) -> Bool {
        switch identifier {
        case .screenRecording, .timeBasedRisk:
            return false
        default:
            return true
        }
    }

    static func loadCompleteState(
        identifier: ComponentIdentifier,
        context: ModelContext
    ) -> (userScore: Int?, userConfirmed: Bool?)? {
        guard shouldPersist(identifier) else { return nil }

        let id = identifier.rawValue
        let descriptor = FetchDescriptor<StoredComponent>(
            predicate: #Predicate { $0.identifier == id }
        )

        guard let stored = try? context.fetch(descriptor).first else {
            return nil
        }

        // Check if data is stale (older than 30 days)
        let daysSince = Calendar.current.dateComponents(
            [.day],
            from: stored.lastUpdated,
            to: Date()
        ).day ?? 0

        if daysSince > 30 {
            return nil // treat as expired
        }

        return (stored.userScore, stored.userConfimed)
    }
}
