//
//  DeviceLockQuestionsView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/12/25.
//

import SwiftUI

struct DeviceLockQuestionsView: View {
    @ObservedObject var detector: DeviceLockSecurityDetector
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
                    onConfirm: detector.confirmSixDigitPasscode
                )

                questionCard(
                    question: "Is your passcode strong (not 123456, 000000, birthdate, etc.)?",
                    explanation: "Simple patterns are easily guessed by attackers",
                    confirmed: detector.userConfirmedStrongPasscode,
                    onConfirm: detector.confirmStrongPasscode
                )

                questionCard(
                    question: "Does your device auto-lock within 5 minutes or less?",
                    explanation: "Quick auto-lock prevents access if you forget to lock your device",
                    confirmed: detector.userConfirmedQuickAutoLock,
                    onConfirm: detector.confirmQuickAutoLock
                )
            }
            .padding(.horizontal, 16)
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
}

#Preview {
    DeviceLockQuestionsView(
        detector: .init(),
        onComplete: {

        }
    )
}
