//
//  FloatingThemePickerButton.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/8/25.
//

import SwiftUI

struct FloatingThemePickerButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var showThemePicker: Bool

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showThemePicker = true
                }) {
                    ZStack {
                        Circle()
                            .fill(themeManager.currentTheme.previewGradient)
                            .frame(width: 40, height: 40)
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

                        Image(systemName: "paintpalette.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.trailing, 20)
                .padding(.top, 100)
            }
            Spacer()
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    FloatingThemePickerButton(showThemePicker: .constant(false))
        .environmentObject(mockThemeManager)
}
