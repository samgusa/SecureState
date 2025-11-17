//
//  SettingsToggleCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/13/25.
//

import SwiftUI
import SwiftData

struct SettingsSectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) var modelContext
    @State var showClearDataConfirmation: Bool = false
    @Binding var badgeRefreshTrigger: Bool
    let settingsResetAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
                .fontWeight(.semibold)
                .themedForeground(themeManager.currentTheme.primary)

            VStack(spacing: 12) {
                // Pro Status / Upgrade Card
                ProStatusCard()

                // About Section

                AboutCard()

                // Privacy policy
                PrivacyCard()

                // DataManager
                DataManagementSection(
                    showClearDataConfirmation: $showClearDataConfirmation
                )

                AchievementsCard(badgeRefreshTrigger: $badgeRefreshTrigger)

#if DEBUG
                DebugSection()
#endif
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


#Preview("Free User") {
    // We wrap setup code in a closure that returns the view.
    let view: some View = {
        let mockThemeManager = ThemeManager()
        let mockStoreManager = EnhancedStoreManager()
        let freeProManager = ProStatusManager(storeManager: mockStoreManager)
        freeProManager.isPro = false  // not pro

        return SettingsSectionView(badgeRefreshTrigger: .constant(false), settingsResetAction: { })
            .environmentObject(mockThemeManager)
            .environmentObject(freeProManager)
            .environmentObject(mockStoreManager)
    }()
    return view
}

#Preview("Pro User") {
    let view: some View = {
        let mockThemeManager = ThemeManager()
        let mockStoreManager = EnhancedStoreManager()
        let proManager = ProStatusManager(storeManager: mockStoreManager, debug: true)

        return SettingsSectionView(badgeRefreshTrigger: .constant(false), settingsResetAction: { })
            .environmentObject(mockThemeManager)
            .environmentObject(proManager)
            .environmentObject(mockStoreManager)
    }()
    return view
}
