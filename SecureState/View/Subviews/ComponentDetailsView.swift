//
//  ComponentDetailsView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/15/25.
//

import SwiftUI

struct ComponentDetailsView: View {
    var securitySection: SecuritySection
    @Binding var selectedSection: SecuritySection?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(securitySection.rawValue.capitalized) Components")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()

                Button("Done") {
                    withAnimation(.spring()) {
                        selectedSection = nil
                    }
                }
                .font(.caption)
                .foregroundStyle(.blue)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(mockComponents(for: securitySection), id: \.name) { component in
//                    ComponentCard(component: component)
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
    }

    func mockComponents(for section: SecuritySection) -> [SecurityComponent] {
        switch section {
        case .device:
            return [
                SecurityComponent(name: "VPN Status", score: 10, maxScore: 15, icon: "shield", status: .good),
                SecurityComponent(name: "Password Manager", score: 10, maxScore: 10, icon: "key", status: .good),
                SecurityComponent(name: "iOS Version", score: 8, maxScore: 10, icon: "gear", status: .warning),
                SecurityComponent(name: "Network Type", score: 6, maxScore: 10, icon: "wifi", status: .caution),
                SecurityComponent(name: "Device Lock", score: 10, maxScore: 10, icon: "lock", status: .good),
                SecurityComponent(name: "Screen Recording", score: 5, maxScore: 5, icon: "eye.slash", status: .good),
                SecurityComponent(name: "Device Model", score: 4, maxScore: 5, icon: "iphone", status: .warning)
            ]
        case .situational:
            return [
                SecurityComponent(name: "Public Wi-Fi", score: 10, maxScore: 15, icon: "wifi.exclamationmark", status: .warning),
                SecurityComponent(name: "Location Context", score: 8, maxScore: 10, icon: "location", status: .caution),
                SecurityComponent(name: "Time Risk", score: 5, maxScore: 5, icon: "clock", status: .good),
                SecurityComponent(name: "Background Activity", score: 5, maxScore: 5, icon: "app.badge", status: .good)
            ]
        }
    }
}

#Preview {
    ComponentDetailsView(
        securitySection: .device,
        selectedSection: .constant(.device)
    )
}
