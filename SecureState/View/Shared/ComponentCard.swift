//
//  ComponentCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct ComponentCard: View {
    let component: SecurityComponent
    let needsAttention: Bool
    let onConfirm: (Bool) -> Void
    let networkType: String

    @State private var pulseAnimation: Bool = false
    @State private var showConfirmationSheet: Bool = false

    var body: some View {
        Button {
            if needsAttention {
                showConfirmationSheet = true
            } else {
                onConfirm(true)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Component Icon with status overlay
                    ZStack {
                        Image(systemName: component.icon)
                            .foregroundStyle(component.status.color)
                            .font(.title3)

                        // Attention Indicator
                        if needsAttention {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.orange)
                                .font(.caption)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(component.score)/\(component.maxScore)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        // Detection Method Indicator
                        if needsAttention {
                            Text("Needs Confirmation")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                Text(component.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 4)
                            .clipShape(RoundedRectangle(cornerRadius: 2))

                        Rectangle()
                            .fill(needsAttention ? .orange : component.status.color)
                            .frame(width: geometry.size.width * component.percentage, height: 4)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                            .animation(.easeInOut(duration: 0.8), value: component.percentage)
                    }
                }
                .frame(height: 4)

                // Attention Message
                if needsAttention {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("Tap to confirm status")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(needsAttention ? Color.orange.opacity(0.05) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(needsAttention ? Color.orange.opacity(0.3) : .clear, lineWidth: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if needsAttention {
                pulseAnimation = true
            }
        }
        .sheet(isPresented: $showConfirmationSheet) {
            ComponentConfirmationSheet(
                component: component,
                onConfirm: { confirmed in
                    onConfirm(confirmed)
                    showConfirmationSheet = false
                },
                onDismiss: {
                    showConfirmationSheet = false
                },
                networkType: networkType
            )
        }

    }
}

#Preview {
//    ComponentCard(
//        component: SecurityComponent(
//            name: "Test",
//            score: 15,
//            maxScore: 20,
//            icon: "shield",
//            status: .good
//        )
//    )
}
