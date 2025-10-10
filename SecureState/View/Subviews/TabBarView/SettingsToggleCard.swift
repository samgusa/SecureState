//
//  SettingsToggleCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/13/25.
//

import SwiftUI
import SwiftData

struct SettingsToggleCard: View {
    @Environment(\.modelContext) var modelContext
    @State var showClearDataConfirmation: Bool = false
    let settingsResetAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                Button {
                    showClearDataConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundStyle(.red)
                        Text("Clear All Saved Data")
                            .foregroundStyle(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

        }
        .alert("Clear All Data?", isPresented: $showClearDataConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                // Button Action
                clearAllPersistedData()
            }
        } message: {
            Text("This will remove all saved security assessments, remembered networks, and location contexts. You'll need to re-confirm your security settings.")
        }
    }

    private func clearAllPersistedData() {
        // clear components
        let componentDescriptor = FetchDescriptor<StoredComponent>()
        if let components = try? modelContext.fetch(componentDescriptor) {
            for component in components {
                modelContext.delete(component)
            }
        }

        // clear networks
        let networkDescriptor = FetchDescriptor<RememberedNetwork>()
        if let networks = try? modelContext.fetch(networkDescriptor) {
            for network in networks {
                modelContext.delete(network)
            }
        }

        // clear locations
        let locationDescriptor = FetchDescriptor<RememberedLocation>()
        if let locations = try? modelContext.fetch(locationDescriptor) {
            for location in locations {
                modelContext.delete(location)
            }
        }

        try? modelContext.save()

        settingsResetAction()

    }


}

#Preview {
    SettingsToggleCard(settingsResetAction: { })
}
