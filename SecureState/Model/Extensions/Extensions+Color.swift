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

    var luminance: Double {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return 0.299 * Double(red) + 0.587 * Double(green) + 0.114 * Double(blue)
    }

    func adjustedForText(colorScheme: ColorScheme) -> Color {
        // Convert to UIColor for HSB
        let ui = UIColor(self)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

        var newB = b

        // If too bright → darken 20%
        if colorScheme == .light {
            if b > 0.85 {
                newB -= 0.15
            }

        } else {
            if b > 0.40 {
                newB += 0.20
            }
        }

        return Color(hue: h, saturation: s, brightness: newB)
    }

    func contrastingTextColor() -> Color {
        // 1. Convert SwiftUI Color to UIColor
        let uiColor = UIColor(self)

        // 2. Extract the RGB components
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        // 3. Calculate Relative Luminance
        // Luminance Formula (ITU-R BT.709): L = 0.2126*R + 0.7152*G + 0.0722*B
        let luminance = (0.2126 * r) + (0.7152 * g) + (0.0722 * b)

        // 4. Determine Contrast
        // The threshold determines what is considered "light" (0.5 is standard)
        if luminance > 0.5 {
            return .black // Light background -> Use dark text
        } else {
            return .white // Dark background -> Use light text
        }
    }
}
