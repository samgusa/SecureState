//
//  StoredComponent.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//

import Foundation
import CryptoKit
import SwiftData

@Model
final class StoredComponent: ObservableObject, Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var identifier: String
    var autoScore: Int
    var userScore: Int?
    var userConfimed: Bool?
    var maxScore: Int
    var metadataJSON: String?
    var lastUpdated: Date = Date.now

    init(identifier: String, autoScore: Int, userScore: Int? = nil, userConfimed: Bool? = nil, maxScore: Int, metadataJSON: String? = nil, lastUpdated: Date = Date.now) {
        self.identifier = identifier
        self.autoScore = autoScore
        self.userScore = userScore
        self.userConfimed = userConfimed
        self.maxScore = maxScore
        self.metadataJSON = metadataJSON
        self.lastUpdated = lastUpdated
    }
}
