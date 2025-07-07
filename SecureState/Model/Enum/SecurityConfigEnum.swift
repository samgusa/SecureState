//
//  SecurityConfigEnum.swift
//  SecureState
//
//  Created by Sam Greenhill on 7/6/25.
//

import SwiftUI
import Foundation

enum SecurityConfigEnum {
    static let maxDevice: Double = 45
    static let maxSituational: Double = 35

    enum Level: Double, CaseIterable {
        case excellent = 0.85
        case good = 0.70
        case moderate = 0.55
        case high = 0.40

        var data: (String, Color, String, Color, [Color]) {
            switch self {
            case .excellent:
                return ("Excellent Security", .green, "shield.checkered", .green, [.green, .mint])
            case .good:
                return ("Good Protection", .mint, "shield", .green, [.green, .mint])
            case .moderate:
                return ("Moderate Risk", .orange, "shield.slash", .orange, [.orange, .yellow])
            case .high:
                return ("High Risk", .red, "exclamationmark.shield", .red, [.red, .pink])
            }
        }

        static func from(percentage: Double) -> Level {
            allCases.first { percentage >= $0.rawValue } ?? .high
        }
    }
}
