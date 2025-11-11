//
//  UpdateCheckSecton.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct UpdateCheckSecton: View {
    @EnvironmentObject var themeManager: ThemeManager

    private let testSteps = [
        "Open the Settings app",
        "Tap **General**",
        "Select **Software Update**",
        "Check if your iPhone is running the latest iOS version"
    ]

    let onConfirmation: (Bool) -> Void
    @State private var currentStep: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Check for iOS Updates")
                .font(.headline)
                .fontWeight(.semibold)

            ForEach(Array(testSteps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(index <= currentStep ? themeManager.currentTheme.primary : Color(.systemGray5))
                            .frame(width: 24, height: 24)

                        if index < currentStep {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(index == currentStep ? .white : .secondary)
                        }
                    }
                    Text(LocalizedStringKey(step))
                        .font(.subheadline)
                        .foregroundStyle(index <= currentStep ? .primary : .secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .opacity(index <= currentStep + 1 ? 1.0 : 0.5)
            }

            HStack {
                if currentStep < testSteps.count - 1 {
                    Button("Next Step") {
                        withAnimation(.spring()) {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                if currentStep > 0 {
                    Button("Previous") {
                        withAnimation(.spring()) {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(.plain)
                }
                Spacer()

                if currentStep == testSteps.count - 1 {
                    Button("I'm Up to Date") {
                        onConfirmation(true)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Update Available") {
                        onConfirmation(false)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .padding()
        .themedBackground(0.1)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    UpdateCheckSecton(onConfirmation: { _ in })
        .environmentObject(mockThemeManager)
}
