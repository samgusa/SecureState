//
//  QuestionCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/12/25.
//

import Foundation
import SwiftUI

func questionCard(question: String, explanation: String, confirmed: Bool?, onConfirm: @escaping (Bool) -> Void) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        Text(question)
            .font(.subheadline)
            .fontWeight(.medium)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .layoutPriority(1)


        Text(explanation)
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)


        HStack(spacing: 12) {
            Button("Yes") {
                onConfirm(true)
            }
            .buttonStyle(ConfirmationButtonStyle(selected: confirmed == true, color: .green))

            Button("No") {
                onConfirm(false)
            }
            .buttonStyle(ConfirmationButtonStyle(selected: confirmed == false, color: .red))
        }
    }
    .padding()
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .frame(maxWidth: .infinity)
}


#Preview {
    DeviceLockQuestionsView(
        detector: .init(),
        onComplete: {

        }
    )
}
