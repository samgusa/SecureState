//
//  ThemePickerView.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI
import SwiftData

struct ThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var proManager: ProStatusManager
    @EnvironmentObject var achievementsManager: AchievementsManager
    @Environment(\.dismiss) var dismiss

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        if !proManager.isPro {
                            proUpgradePrompt
                        } else {
                            themeGrid
                        }
                    }
                    .padding()
                }
                .navigationTitle("Color Themes")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    // Scroll to selected theme on appear
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(themeManager.currentTheme.rawValue, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    private var proUpgradePrompt: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
            }
            Text("Custom Color Themes")
                .font(.title2)
                .fontWeight(.bold)

            Text("Personalize your security dashboard with beautiful color palettes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                FeatureBullet(icon: "paintbrush.fill", text: "10 handcrafted color themes", color: .purple)
                FeatureBullet(icon: "sparkles", text: "Beautifully designed palettes", color: .pink)
                FeatureBullet(icon: "eye.fill", text: "Optimized for readability", color: themeManager.currentTheme.primary)
            }
            .padding()
            .themedBackground(0.1)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 40)
    }

    private var themeGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(AppColorTheme.allCases, id: \.rawValue) { theme in
                ThemePreviewCard(
                    theme: theme,
                    isSelected: themeManager.currentTheme == theme) {
                        themeManager.setTheme(theme)
                        achievementsManager.trackThemeUsed(theme.rawValue)
                    }
                    .id(theme.rawValue)

                ThemeContrastTester(theme: theme)
                    .onTapGesture {
                        themeManager.setTheme(theme)
                    }
            }
        }
    }
}

#Preview("Free User") {
    // We wrap setup code in a closure that returns the view.
    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let view: some View = {
        let achievementManager = AchievementsManager(modelContext: container.mainContext)
        let mockThemeManager = ThemeManager()
        let mockStoreManager = EnhancedStoreManager()
        let freeProManager = ProStatusManager(storeManager: mockStoreManager)
        freeProManager.isPro = false  // not pro

        return ThemePickerView()
            .environmentObject(mockThemeManager)
            .environmentObject(freeProManager)
            .environmentObject(achievementManager)
    }()
    return view
}

#Preview("Pro User") {
    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let view: some View = {
        let achievementManager = AchievementsManager(modelContext: container.mainContext)
        let mockThemeManager = ThemeManager()
        let mockStoreManager = EnhancedStoreManager()
        let proManager = ProStatusManager(storeManager: mockStoreManager, debug: true)

        return ThemePickerView()
            .environmentObject(mockThemeManager)
            .environmentObject(proManager)
            .environmentObject(achievementManager)
    }()
    return view
}


