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
}

enum ComponentState {
    case autoDetected(score: Int, confidence: ConfidenceLevel)
    case userConfirmed(autoScore: Int?, userScore: Int)
    case userOnly(score: Int)
    case needsUserInput(autoScore: Int?, reason: String)
}
