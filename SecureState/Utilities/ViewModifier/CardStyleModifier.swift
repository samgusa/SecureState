//
//  CardStyleModifier.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI
import Foundation

struct CardStyleModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let strokeColor: Color
    let strokeOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(
                colorScheme == .dark ?
                Color(.tertiarySystemBackground) :
                    Color(.secondarySystemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(
                color: Color.black.opacity(0.18),
                radius: 5,
                x: 0, y: 3
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        strokeColor.opacity(
                            colorScheme == .dark ? max(strokeOpacity * 2, 0.5) : strokeOpacity
                        ),
                        lineWidth: colorScheme == .dark ? 1.5 : 1
                    )
            }
    }
}
