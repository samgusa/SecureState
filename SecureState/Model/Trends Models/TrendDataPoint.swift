//
//  TrendDataPoint.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation

struct TrendDataPoint: Codable, Identifiable {
    let id: UUID
    let date: Date
    let vulnerabilityCount: Int
    let criticalCount: Int
    let highCount: Int
    let mediumCount: Int

    init(date: Date, total: Int, critical: Int, high: Int, medium: Int) {
        self.id = UUID()
        self.date = date
        self.vulnerabilityCount = total
        self.criticalCount = critical
        self.highCount = high
        self.mediumCount = medium
    }
}
