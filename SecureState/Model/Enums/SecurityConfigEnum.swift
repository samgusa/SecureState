//
//  SecurityConfigEnum.swift
//  SecureState
//
//  Created by Sam Greenhill on 7/6/25.
//

import SwiftUI
import Foundation

enum SecurityConfigEnum {
    static let maxDevice: Double = 55
    static let maxSituational: Double = 45

    enum Level: Double, CaseIterable {
        case excellent = 0.85
        case good = 0.70
        case moderate = 0.55
        case high = 0.40

        var data: SecurityLevelInfo {
            switch self {
            case .excellent:
                return SecurityLevelInfo(message: "Excellent", baseColor: .green, icon: "shield.checkerboard")
            case .good:
                return SecurityLevelInfo(message: "Good", baseColor: .green, icon: "shield")
            case .moderate:
                return SecurityLevelInfo(message: "Moderate", baseColor: .orange, icon: "exclamationmark.triangle")
            case .high:
                return SecurityLevelInfo(message: "High Risk", baseColor: .red, icon: "xmark.shield")
            }
        }

        static func from(percentage: Double) -> Level {
            allCases.first { percentage >= $0.rawValue } ?? .high
        }
    }
}
