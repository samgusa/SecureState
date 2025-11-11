//
//  ContentView.swift
//  SecureState
//
//  Created by Sam Greenhill on 5/27/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @StateObject private var achievementsManager: AchievementsManager

    init() {
        // This will be properly initialized when the view appears
        let context = PersistenceController.shared.container.mainContext
        _achievementsManager = StateObject(wrappedValue: AchievementsManager(modelContext: context))
    }


    var body: some View {
        Home()
            .environmentObject(achievementsManager)
    }
}

#Preview {
    ContentView()
}
