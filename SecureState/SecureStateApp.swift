//
//  SecureStateApp.swift
//  SecureState
//
//  Created by Sam Greenhill on 5/27/25.
//

import SwiftUI
import SwiftData

@main
struct SecureStateApp: App {

    @StateObject private var storeManager = EnhancedStoreManager()
    @StateObject private var proManager: ProStatusManager
    @StateObject private var themeManager = ThemeManager()
    @State private var achievementsManager: AchievementsManager?

    init() {
        if APIKeyManager.retrieveNVDKey() == nil {
            if let keyPath = Bundle.main.path(forResource: "SecureKeys", ofType: "plist"),
               let dict = NSDictionary(contentsOfFile: keyPath),
               let apiKey = dict["NVD_API_KEY"] as? String {
                _ = APIKeyManager.storeNVDKey(apiKey)
            } else {
                print("Warning: Missing NVD_API_KEY in SecureKeys.plist")
            }
        }

        // Initialize Store Manager
        let store = EnhancedStoreManager()
        _storeManager = StateObject(wrappedValue: store)

        // Initialize Pro Manager with Store Manager
        _proManager = StateObject(wrappedValue: ProStatusManager(storeManager: store))
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(PersistenceController.shared.container)
                .environmentObject(storeManager)
                .environmentObject(proManager)
                .environmentObject(themeManager)
        }


    }
}
