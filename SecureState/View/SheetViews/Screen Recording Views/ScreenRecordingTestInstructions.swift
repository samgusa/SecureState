//
//  ScreenRecordingTestInstructions.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct ScreenRecordingTestInstructions: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    let onTestCompleted: () -> Void
    @State private var currentStep: Int = 0
    private let testSteps = [
        "Open Control Center by swiping down from the top-right corner",
        "Look for the screen recording button (circle with a dot inside)",
        "Tap the screen recording button to start recording",
        "Return to this app and watch the indicator change to red",
        "Open Control Center again and tap the red recording indicator at the top to stop"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Screen Recording Test")
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
                                .foregroundStyle(stepTextColor(for: index))

                        }
                    }
                    Text(step)
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
                    Button("Complete Test") {
                        onTestCompleted()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
        .padding()
        .cardStyle(themeManager.currentTheme.primary)
    }

    private func stepTextColor(for index: Int) -> Color {
        if index == currentStep {
            if themeManager.currentTheme == .default && colorScheme == .dark {
                return .black
            } else {
                return .white
            }
        } else {
            return .secondary
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    ScreenRecordingTestInstructions(onTestCompleted: {

    })
    .environmentObject(mockThemeManager)
}
