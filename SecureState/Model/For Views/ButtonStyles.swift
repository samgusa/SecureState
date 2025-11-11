//
//  ButtonStyles.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/14/25.
//

import SwiftUI
import UIKit

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager

    func makeBody(configuration: Configuration) -> some View {
        let textColor: Color = .white

        let gradient = LinearGradient(
            colors: [
                themeManager.currentTheme.primary,
                themeManager.currentTheme == .default ? themeManager.currentTheme.primary : themeManager.currentTheme.accent
            ],
            startPoint: .leading,
            endPoint: .trailing
        )

        configuration.label
            .font(.headline)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(gradient)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @EnvironmentObject var themeManager: ThemeManager

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(themeManager.currentTheme.primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(themeManager.currentTheme.primary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.currentTheme.primary, lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct ConfirmationButtonStyle: ButtonStyle {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    let selected: Bool
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(selected ? .white : themeManager.currentTheme.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                selected ?
                color :
                    color.opacity(colorScheme == .dark ? 0.15 : 0.05)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        selected ? Color.clear : color.opacity(colorScheme == .dark ? 0.5 : 0.3),
                        lineWidth: selected ? 0 : 1.5
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ThemedPrimaryButtonStyle: ButtonStyle {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    var color: Color?

    func makeBody(configuration: Configuration) -> some View {
        let baseColor = color ?? themeManager.currentTheme.primary

        configuration.label
            .font(.headline)
            .foregroundStyle(themeManager.currentTheme == .default ? .white : .black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color ?? themeManager.currentTheme.accent.opacity(0.85))
                    .shadow(
                        color: colorScheme == .dark
                        ? .black.opacity(0.4)
                        : baseColor.opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
