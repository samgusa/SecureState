//
//  RememberedNetwork.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//

import Foundation
import SwiftData

@Model
final class RememberedNetwork: ObservableObject, Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var ssid: String
    var trustLevel: Int
    var label: String
    var timestamp: Date = Date.now

    init(ssid: String, trustLevel: Int = 0, label: String) {
        self.ssid = ssid
        self.trustLevel = trustLevel
        self.label = label
    }
}
