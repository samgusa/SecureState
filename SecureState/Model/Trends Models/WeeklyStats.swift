//
//  WeeklyStats.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation

struct WeeklyStats {
    let totalCount: Int                 // ~997 from api
    let criticalCount: Int              // ~ 200- from api or estimation
    let highCount: Int                  // ~ 400- from api or estimation
    let mediumCount: Int                // ~ 300- from api or estimation
    let dateRange: String               // "Date Here"
}
