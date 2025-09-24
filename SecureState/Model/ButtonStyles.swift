//
//  ButtonStyles.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/14/25.
//

import SwiftUI
import UIKit

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)

    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct ConfirmationButtonStyle: ButtonStyle {
    let selected: Bool
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(selected ? .white : color)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(selected ? color : color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color, lineWidth: selected ? 0 : 1)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
