//
//  Extensions+Color.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
    static func adaptive(light: UIColor, dark: UIColor) -> Color {
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}
