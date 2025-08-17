//
//  ComponentType.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/15/25.
//

import Foundation
import SwiftUI

enum ComponentType {
    case simple
    case contextual
    case complex

    var presentationDetent: PresentationDetent {
        switch self {
        case .simple: return .fraction(0.4)
        case .contextual:  return .fraction(0.6)
        case .complex: return .large
        }
    }
}
