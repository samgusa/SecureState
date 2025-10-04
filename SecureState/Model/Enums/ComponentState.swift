//
//  ComponentState.swift
//  SecureState
//
//  Created by Sam Greenhill on 7/6/25.
//

import SwiftUI
import Foundation

enum ConfidenceLevel {
    case high
    case medium
    case low
    case failed

    var color: Color {
        switch self {
        case .high: return .green
        case .medium: return .yellow
        case .low: return .orange
        case .failed: return .red
        }
    }

    var level: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        case .failed: return "Failed"
        }
    }

    var description: String {
        switch self {
        case .high: return "Auto-detection reliable"
        case .medium: return "Some user input needed"
        case .low: return "User confirmation recommended"
        case .failed: return "Detection failed"
        }
    }
}

enum ComponentState {
    case autoDetected(score: Int, confidence: ConfidenceLevel)
    case userConfirmed(autoScore: Int?, userScore: Int)
    case userOnly(score: Int)
    case needsUserInput(autoScore: Int?, reason: String)
}
