//
//  Extension+View.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI

extension View {
    func themedBackground(_ opacity: Double = 0.05) -> some View {
        self.modifier(ThemedBackgroundModifier(opacity: opacity))
    }

    func cardStyle(_ strokeColor: Color = .primary, _ opacity: Double = 0.25) -> some View {
        self
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(
                color: Color.black.opacity(0.18),
                radius: 5, x: 0, y: 3
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        strokeColor.opacity(opacity), // adapts to light and dark
                        lineWidth: 1
                    )
            }
    }
}
