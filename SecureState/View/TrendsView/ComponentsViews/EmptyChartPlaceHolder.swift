//
//  EmptyChartPlaceHolder.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI

struct EmptyChartPlaceHolder: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No trend data yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Pull to refresh or check back tomorrow")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyChartPlaceHolder()
}
