//
//  DataStore.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//

import Foundation
import CoreLocation
import SwiftData

struct DataStore {
    static let maxSavedEntries = 50

    // Upsert StoredComponent
    static func upsertComponent(identifier: ComponentIdentifier, autoScore: Int, userScore: Int? = nil, userConfirmed: Bool? = nil, maxScore: Int, context: ModelContext) {
        let id = identifier.rawValue
        let descriptor = FetchDescriptor<StoredComponent>(
            predicate: #Predicate { $0.identifier == id }
        )
        if let existing = try? context.fetch(descriptor).first {
            existing.autoScore = autoScore
            existing.userScore = userScore
            existing.userConfimed = userConfirmed
            existing.lastUpdated = Date()
            try? context.save()
            return
        }
        let newEntity = StoredComponent(
            identifier: identifier.rawValue,
            autoScore: autoScore,
            userScore: userScore,
            userConfimed: userConfirmed,
            maxScore: maxScore
        )
        context.insert(newEntity)
        try? context.save()
    }

    // Remember network (stored hash only)
    static func rememberNetwork(ssid: String, trustLevel: Int = 1, label: String? = nil, context: ModelContext) {
        let hashed = ssid.sha256Hex()
        let descriptor = FetchDescriptor<RememberedNetwork>(
            predicate: #Predicate { $0.ssid == hashed }
        )
        if let existing = try? context.fetch(descriptor).first {
            existing.trustLevel = trustLevel
            existing.label = label ?? ""
            existing.timestamp = Date()
            try? context.save()
            return
        }
        let item = RememberedNetwork(ssid: hashed, trustLevel: trustLevel, label: label ?? "")
        context.insert(item)
        try? context.save()
        enforceNetworkLimit(context: context)
    }

    static func enforceNetworkLimit(context: ModelContext) {
        guard let all = try? context.fetch(FetchDescriptor<RememberedNetwork>()).sorted(by: { $0.timestamp > $1.timestamp }), all.count > maxSavedEntries else { return }
        let toDelete = all.suffix(from: maxSavedEntries)
        for item in toDelete { context.delete(item) }
        try? context.save()
    }

    // Remember Location (coarsened)
    static func rememberLocation(coord: CLLocationCoordinate2D, contextLabel: String, displayName: String? = nil, context: ModelContext) {
        let geohash = coarsen(coord)
        let descriptor = FetchDescriptor<RememberedLocation>(
            predicate: #Predicate { $0.geohash == geohash }
        )
        if let existing = try? context.fetch(descriptor).first {
            existing.context = contextLabel
            existing.displayName = displayName
            existing.timestamp = Date()
            try? context.save()
            return
        }
        let item = RememberedLocation(geohash: geohash, context: contextLabel, displayName: displayName)
        context.insert(item)
        try? context.save()
        enforceLocationLimit(context: context)
    }

    static func enforceLocationLimit(context: ModelContext) {
        guard let all = try? context.fetch(FetchDescriptor<RememberedLocation>()).sorted(by: { $0.timestamp > $1.timestamp }), all.count > maxSavedEntries else { return }
        let toDelete = all.suffix(from: maxSavedEntries)
        for item in toDelete { context.delete(item) }
        try? context.save()
    }
}


func coarsen(_ coord: CLLocationCoordinate2D, precision: Int = 3) -> String {
    let mult = pow(10.0, Double(precision))
    let lat = Double(round(mult * coord.latitude) / mult)
    let lon = Double(round(mult * coord.longitude) / mult)
    return "\(lat)_\(lon)"
}
