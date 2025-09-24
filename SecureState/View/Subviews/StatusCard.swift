//
//  StatusCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import Foundation
import SwiftUI

func statusCard(_ title: String, _ status: String, _ color: Color) ->  some View {
    HStack {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(status)
                .font(.caption)
                .foregroundStyle(color)
        }
        Spacer()

        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
    }
    .padding()
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 8))
}
