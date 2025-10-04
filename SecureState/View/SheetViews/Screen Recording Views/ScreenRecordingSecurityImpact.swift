//
//  ScreenRecordingSecurityImpact.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct ScreenRecordingSecurityImpact: View {
    let risks = [
        ("Passwords", "Visible when typing or displayed on screen"),
        ("Banking Info", "Account numbers, balances, transactions"),
        ("Private Messages", "Texts, emails, chat conversations"),
        ("Sensitive Documents", "Photos, PDFs, personal files"),
        ("App Content", "Any information displayed in apps")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.shield.fill")
                    .foregroundStyle(.orange)

                Text("What Gets Captured During Recording")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(risks, id: \.0) { risk in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "eye.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(width: 16)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(risk.0)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text(risk.1)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        }
    }
}

#Preview {
    ScreenRecordingSecurityImpact()
}
