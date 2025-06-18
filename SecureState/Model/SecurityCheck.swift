//
//  SecurityCheck.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import Foundation
import SwiftUI

enum SecuritySection: String, CaseIterable {
    case device = "device"
    case situational = "situational"
}

enum ComponentStatus {
    case good, warning, caution

    var color: Color {
        switch self {
        case .good: return .green
        case .warning: return .orange
        case .caution: return .red
        }
    }
}
