//
//  SimpleCVE.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI

struct SimpleCVE: Identifiable, Codable {
    let id: String
    let severity: Severity
    let published: Date
    let description: String
    let weaknessType: String?
    let affectedProducts: [String]

    enum Severity: String, Codable, CaseIterable {
        case critical = "CRITICAL"
        case high = "HIGH"
        case medium = "MEDIUM"
        case low = "LOW"
        case unknown = "UNKNOWN"

        var color: Color {
            switch self {
            case .critical: return .red
            case .high: return .orange
            case .medium: return .yellow
            case .low: return .blue
            case .unknown: return .purple
            }
        }

        var displayName: String {
            return rawValue.capitalized
        }

        func displayColor(for colorScheme: ColorScheme) -> Color {
            switch self {
            case .medium:
                return colorScheme == .light ? Color(red: 0.85, green: 0.65, blue: 0.0) : .yellow
            default:
                return self.color
            }
        }
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: published)
    }

    var userFriendlyType: String {
        if let weakness = weaknessType {
            return weakness
        }
        return "Security Vulnerability"
    }

}

