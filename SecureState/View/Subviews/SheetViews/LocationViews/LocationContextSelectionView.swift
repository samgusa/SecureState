//
//  LocationContextSelectionView.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/20/25.
//

import SwiftUI

struct LocationContextSelectionView: View {
    @ObservedObject var detector: EnhancedLocationContextDetector
    let onSelection: (EnhancedLocationContextDetector.LocationSecurityContext) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Security Context")
                .font(.headline)

            LazyVStack(spacing: 8) {
                ForEach(EnhancedLocationContextDetector.LocationSecurityContext.allCases, id: \.rawValue) { context in
                    Button {
                        detector.selectContext(context)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(context.color.opacity(0.1))
                                    .frame(width: 36, height: 36)

                                Image(systemName: context.icon)
                                    .font(.system(size: 16))
                                    .foregroundStyle(context.color)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(context.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)

                                Text(context.riskDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if detector.userSelectedContext == context {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else {
                                Text("\(context.securityScore)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(context.color)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            detector.userSelectedContext == context ? context.color.opacity(0.1) : Color(.systemGray6)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    detector.userSelectedContext == context ? context.color : Color.clear,
                                    lineWidth: 2
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    Home()
}
