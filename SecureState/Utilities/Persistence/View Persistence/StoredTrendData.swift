//
//  StoredTrendData.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class StoredTrendData {
    var id: UUID
    var date: Date
    var vulnerabilityCount: Int
    var criticalCount: Int
    var highCount: Int
    var mediumCount: Int

    init(date: Date, total: Int, critical: Int, high: Int, medium: Int) {
        self.id = UUID()
        self.date = date
        self.vulnerabilityCount = total
        self.criticalCount = critical
        self.highCount = high
        self.mediumCount = medium
    }
}
