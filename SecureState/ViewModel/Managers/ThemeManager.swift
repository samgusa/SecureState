//
//  ThemeManager.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI

// Theme Manager
@MainActor
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppColorTheme {
        didSet {
            Task { @MainActor in
                UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
            }
        }
    }

    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppColorTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .default // Default theme
        }
    }

    func setTheme(_ theme: AppColorTheme) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTheme = theme
        }
    }
}
