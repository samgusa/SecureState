//
//  InfoBox.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/12/25.
//

import Foundation
import SwiftUI

func infoBox(_ text: String) -> some View {
    HStack(spacing: 8) {
        Image(systemName: "info.circle.fill")
            .foregroundStyle(.blue)

        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .padding()
    .background(Color.blue.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 8))
}
