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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
