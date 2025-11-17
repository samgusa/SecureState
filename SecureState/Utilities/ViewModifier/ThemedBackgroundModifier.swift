//
//  ThemedBackgroundModifier.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI

struct ThemedBackgroundModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    let opacity: Double
    let borderOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(
                themeManager.currentTheme.primary.opacity(
                    colorScheme == .dark ?
                    min(opacity * 2.0, 0.25) :
                        opacity
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        themeManager.currentTheme.primary.opacity(borderOpacity),
                        lineWidth: 1
                    )
            }
    }
}
