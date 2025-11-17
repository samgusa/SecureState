//
//  ThemedTextModifier.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/16/25.
//

import SwiftUI

struct ThemedTextModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let color: Color
    let shouldAdjust: Bool


    func body(content: Content) -> some View {
        content
            .foregroundStyle(shouldAdjust ? color.adjustedForText(colorScheme: colorScheme) : color)
    }
}

extension View {
    func themedForeground(_ color: Color, adjusted: Bool = true) -> some View {
        self.modifier(ThemedTextModifier(color: color, shouldAdjust: adjusted))
    }
}
