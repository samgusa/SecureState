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
    case good
    case warning
    case caution

    init(score: Int, maxScore: Int) {
        let percentage = Double(score) / Double(maxScore)
        self = percentage >= 0.8 ? .good : percentage >= 0.5 ? .warning : .caution
    }

    var color: Color {
        switch self {
        case .good: return .green
        case .warning: return .orange
        case .caution: return .red
        }
    }

    func themedColor(theme: AppColorTheme) -> Color {
        switch self {
        case .good: return theme.successColor
        case .warning: return theme.warningColor
        case .caution: return theme.dangerColor
        }
    }
}
