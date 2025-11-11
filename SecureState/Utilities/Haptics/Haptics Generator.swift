//
//  Haptics Generator.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI

struct Haptic {
    static func success() {
        UINotificationFeedbackGenerator()
            .notificationOccurred(.success)
    }
    static func warning() {
        UINotificationFeedbackGenerator()
            .notificationOccurred(.warning)
    }
    static func error() {
        UINotificationFeedbackGenerator()
            .notificationOccurred(.error)
    }
    static func tap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

}
