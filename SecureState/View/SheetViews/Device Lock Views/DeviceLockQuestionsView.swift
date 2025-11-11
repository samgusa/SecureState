//
//  DeviceLockQuestionsView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/12/25.
//

import SwiftUI

struct DeviceLockQuestionsView: View {
    @ObservedObject var detector: DeviceLockSecurityDetector
    @EnvironmentObject var themeManager: ThemeManager
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("About Your Passcode")
                .font(.headline)
                .fontWeight(.medium)

            Text("Help us assess your passcode strength:")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                questionCard(
                    question: "Is your passcode 6 digits long (not just 4)?",
                    explanation: "6-digit passcodes are 100 times stronger than 4-digit ones",
                    confirmed: detector.userConfirmedSixDigitPasscode,
                    themeManager: themeManager,
                    onConfirm: detector.confirmSixDigitPasscode
                )

                questionCard(
                    question: "Is your passcode strong (not 123456, 000000, birthdate, etc.)?",
                    explanation: "Simple patterns are easily guessed by attackers",
                    confirmed: detector.userConfirmedStrongPasscode,
                    themeManager: themeManager,
                    onConfirm: detector.confirmStrongPasscode
                )

                questionCard(
                    question: "Does your device auto-lock within 5 minutes or less?",
                    explanation: "Quick auto-lock prevents access if you forget to lock your device",
                    confirmed: detector.userConfirmedQuickAutoLock,
                    themeManager: themeManager,
                    onConfirm: detector.confirmQuickAutoLock
                )
            }

            if allQuestionsAnswered {
                Button("Complete Assessment") {
                    onComplete()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
    private var allQuestionsAnswered: Bool {
        detector.userConfirmedSixDigitPasscode != nil &&
        detector.userConfirmedStrongPasscode != nil &&
        detector.userConfirmedQuickAutoLock != nil
    }

    @MainActor
    private func questionCard(question: String, explanation: String, confirmed: Bool?, themeManager: ThemeManager, onConfirm: @escaping (Bool) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question)
                .font(.subheadline)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            Text(explanation)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            HStack(spacing: 12) {
                Button("Yes") {
                    onConfirm(true)
                }
                .buttonStyle(ConfirmationButtonStyle(selected: confirmed == true, color: themeManager.currentTheme.successColor))

                Button("No") {
                    onConfirm(false)
                }
                .buttonStyle(ConfirmationButtonStyle(selected: confirmed == false, color: themeManager.currentTheme.dangerColor))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .themedBackground(0.1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    DeviceLockQuestionsView(
        detector: .init(),
        onComplete: {

        }
    )
    .environmentObject(mockThemeManager)
}
