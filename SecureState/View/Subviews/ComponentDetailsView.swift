//
//  ComponentDetailsView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/15/25.
//

import SwiftUI

struct ComponentDetailsView: View {
    @Binding var securitySection: SecuritySection?
    @Binding var selectedComponentForConfirmation: SecurityComponent?
    @State private var showingConfirmationSheet: Bool = false
    @Binding var needsAttentionComponents: Set<String>
    let networkType: String


    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(String(describing: securitySection?.rawValue.capitalized ?? "")) Components")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()

                Button("Done") {
                    withAnimation(.spring()) {
                        securitySection = nil
                    }
                }
                .font(.caption)
                .foregroundStyle(.blue)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(mockComponents(for: securitySection ?? .device), id: \.name) { component in
                    ComponentCard(
                        component: component,
                        needsAttention: needsAttentionComponents.contains(component.name),
                        onConfirm: { confirmed in
                            handleComponentConfirmation(component: component, confirmed: confirmed)
                        },
                        networkType: networkType
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .transition(
            .asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .opacity
            )
        )
        .sheet(isPresented: $showingConfirmationSheet) {

            ComponentConfirmationSheet(
                component: selectedComponentForConfirmation ?? SecurityComponent(
                    name: "Password Manager",
                    score: 10,
                    maxScore: 10,
                    icon: "key"
                ),
                onConfirm: { confirmed in
                    showingConfirmationSheet = false
                },
                onDismiss: {
                    showingConfirmationSheet = false
                    selectedComponentForConfirmation = nil
                },
                networkType: networkType
            )
        }
    }

    private func handleComponentConfirmation(component: SecurityComponent, confirmed: Bool) {
        
    }

    func mockComponents(for section: SecuritySection) -> [SecurityComponent] {
        switch section {
        case .device:
            return [
                SecurityComponent(name: "VPN Status", score: 10, maxScore: 15, icon: "shield"),
                SecurityComponent(name: "iOS Version", score: 8, maxScore: 10, icon: "gear"),
                SecurityComponent(name: "Network Type", score: 6, maxScore: 10, icon: "wifi"),
                SecurityComponent(name: "Screen Recording", score: 5, maxScore: 5, icon: "eye.slash")
            ]
        case .situational:
            return [
                SecurityComponent(name: "Public Wi-Fi", score: 10, maxScore: 15, icon: "wifi.exclamationmark"),
                SecurityComponent(name: "Location Context", score: 8, maxScore: 10, icon: "location"),
                SecurityComponent(name: "Time Risk", score: 5, maxScore: 5, icon: "clock"),
                SecurityComponent(name: "Background Activity", score: 5, maxScore: 5, icon: "app.badge")
            ]
        }
    }
}

#Preview {
    ComponentDetailsView(
        securitySection: .constant(.situational),
        selectedComponentForConfirmation: .constant(
            SecurityComponent(
                name: "Password Manager",
                score: 10,
                maxScore: 10,
                icon: "key"
            )
        ),
        needsAttentionComponents: .constant([]),
        networkType: "testing"
    )
}
