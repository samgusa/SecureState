//
//  SecurityComponent.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import Foundation
import SwiftUI

struct SecurityComponent {
    let name: String
    let score: Int
    let maxScore: Int
    let icon: String
    let status: ComponentStatus

    var percentage: Double {
        Double(score) / Double(maxScore)
    }
}
