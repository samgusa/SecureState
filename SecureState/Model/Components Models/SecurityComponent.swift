//
//  SecurityComponent.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import Foundation
import SwiftUI

struct SecurityComponent {
    let identifier: ComponentIdentifier
    let score: Int
    let maxScore: Int
    let icon: String

    var name: String { identifier.displayName }
    var percentage: Double { Double(score) / Double(maxScore) }
    var status: ComponentStatus { ComponentStatus(score: score, maxScore: maxScore) }

    static func create(_ name: ComponentIdentifier, _ score: Int, _ maxScore: Int, _ icon: String) -> SecurityComponent {
        SecurityComponent(identifier: name, score: score, maxScore: maxScore, icon: icon)
    }
}
