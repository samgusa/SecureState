//
//  RiskBadge.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import SwiftUI

struct RiskBadge: View {
    let count: Int
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 2) {
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption2)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    RiskBadge(
        count: 10,
        color: .blue,
        label: "Testing"
    )
}
