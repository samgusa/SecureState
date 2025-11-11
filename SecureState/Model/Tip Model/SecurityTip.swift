//
//  SecurityTip.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI

struct SecurityTip: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let category: TipCategory?

    enum TipSource: String, Codable {
        case core = "built-in"
        case community = "community"
    }

    enum TipCategory: String, Codable, CaseIterable {
        case network = "Network"
        case device = "Device"
        case privacy = "Privacy"
        case passwords = "Passwords"
        case general = "General"

        var icon: String {
            switch self {
            case .network: return "wifi"
            case .device: return "iphone"
            case .privacy: return "hand.raised.fill"
            case .passwords: return "key.fill"
            case .general: return "lightbulb.fill"
            }
        }

        var color: Color {
            switch self {
            case .network: return .blue
            case .device: return .purple
            case .privacy: return .orange
            case .passwords: return .green
            case .general: return .cyan
            }
        }
    }
}
