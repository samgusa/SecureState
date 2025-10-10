//
//  RememberedLocation.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//

import Foundation
import SwiftData

@Model
final class RememberedLocation: ObservableObject, Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var geohash: String
    var context: String
    var displayName: String?
    var timestamp: Date = Date.now

    init(geohash: String, context: String = "unknown", displayName: String? = nil) {
        self.geohash = geohash
        self.context = context
        self.displayName = displayName
    }
}
