//
//  InterceptedDataView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct InterceptedDataView: View {
    let data: [String]
    let isEncrypted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isEncrypted ? "lock.fill" : "lock.open.fill")
                    .foregroundStyle(isEncrypted ? .green : .red)
                Text("Network Observer Sees:")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(data.suffix(5).enumerated()), id: \.offset) { index, item in
                        Text(item)
                            .font(.caption)
                            .monospaced()
                            .foregroundStyle(isEncrypted ? .green : .red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(isEncrypted ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            .frame(maxHeight: 100)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEncrypted ? Color.green : Color.red, lineWidth: 1)
        }
    }
}

#Preview {
    InterceptedDataView(data: ["Testing 1", "Testing 2", "Testing 3", "Testing 4", "Testing 5", "Testing 6"], isEncrypted: true)
}
