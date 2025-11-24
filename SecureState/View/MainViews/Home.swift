//
//  Home.swift
//  SecureState
//
//  Created by Sam Greenhill on 5/27/25.
//

import SwiftUI
import SwiftData

struct Home: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var proManager: ProStatusManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var achievementsManager: AchievementsManager
    @EnvironmentObject var storeManager: EnhancedStoreManager
    @StateObject var secureState = SecurityViewModel()

    var body: some View {
        NavigationView {
            ZStack {

                contentScrollLayer

                if proManager.isPro {
                    FloatingThemePickerButton(showThemePicker: $secureState.showThemePicker)
                }
                VStack {
                    Spacer()
                    FloatingTabBarView(selectedTab: $secureState.selectedTab)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
            .navigationTitle("Secure State")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $secureState.showThemePicker) {
                ThemePickerView()
                    .environmentObject(themeManager)
                    .environmentObject(proManager)
                    .onDisappear {
                        achievementsManager.trackThemeUsed(themeManager.currentTheme.rawValue)
                    }
            }
            .sheet(isPresented: $secureState.showUpgradeSheet) {
                proManager.showUpgradeSheet()
            }
        }
        .environmentObject(proManager)
        .environmentObject(achievementsManager)
        .onAppear {
            secureState.modelContext = modelContext
            secureState.achievementsManager = achievementsManager
            secureState.setupInitialState()
        }
        .overlay {
            if let achievement = achievementsManager.recentlyUnlocked, proManager.isPro {
                // Achievement unlock notification
                AchievementUnlockedBanner(achievement: achievement)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: achievementsManager.recentlyUnlocked)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .onChange(of: achievementsManager.selectedBadge) { oldValue, newValue in
            withAnimation(.spring()) { }
        }
        .refreshable {
            await secureState.performSecurityRefresh()
        }
    }

    var fixedNotificationReceiver: some View {
        EmptyView()
            .onReceive(NotificationCenter.default.publisher(for: .locationContextSelected), perform: { notification in
                if let context = notification.object as? EnvironmentalSecurityDetector.EnvironmentType {
                    secureState.environmentSecurityDetector.selectEnvironmentType(context)
                    secureState.updateSingleComponent(identifier: .environmentalSecurity)
                }
            })
    }

    func themedScoreColors(for percentage: Double) -> [Color] {
        let baseColor: Color
        switch percentage {
        case 0.8...1.0:
            baseColor = themeManager.currentTheme.successColor
        case 0.6..<0.8:
            baseColor = themeManager.currentTheme.warningColor
        default:
            baseColor = themeManager.currentTheme.dangerColor
        }
        return [baseColor, baseColor.opacity(0.85)]
    }

    var themedDeviceGradient: LinearGradient {
        LinearGradient(
            colors: themedScoreColors(for: secureState.devicePercentage),
            startPoint: .center,
            endPoint: .bottomTrailing
        )
    }

    var themedSituationalGradient: LinearGradient {
        LinearGradient(
            colors: themedScoreColors(for: secureState.situationalPercentage),
            startPoint: .topLeading,
            endPoint: .center
        )
    }

    var situationalGradient: LinearGradient {
        let colors = themedScoreColors(for: secureState.situationalPercentage)
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .center
        )
    }

    var deviceGradient: LinearGradient {
        return LinearGradient(
            colors: themedScoreColors(for: secureState.devicePercentage),
            startPoint: .center,
            endPoint: .bottomTrailing
        )
    }

    var overallScoreColor: Color {
        let percentage = secureState.overallPercentage
        if percentage >= 0.8 {
            return themeManager.currentTheme.successColor
        } else if percentage >= 0.6 {
            return themeManager.currentTheme.warningColor
        } else {
            return themeManager.currentTheme.dangerColor
        }
    }

    func scoreColors(for percentage: Double) -> [Color] {
        switch percentage {
        case 0.8...1.0:
            return [themeManager.currentTheme.successColor, themeManager.currentTheme.successColor.opacity(0.7)]
        case 0.6..<0.8:
            return [themeManager.currentTheme.warningColor, themeManager.currentTheme.warningColor.opacity(0.7)]
        default:
            return [themeManager.currentTheme.dangerColor, themeManager.currentTheme.dangerColor.opacity(0.7)]
        }
    }

    // Security status message based on overall score
    var securityStatus: SecurityStatus {
        let level = secureState.securityLevel
        let info = level.data
        let themedColor: Color

        switch level {
        case .excellent, .good:
            themedColor = themeManager.currentTheme.successColor
        case .moderate:
            themedColor = themeManager.currentTheme.warningColor
        case .high:
            themedColor = themeManager.currentTheme.dangerColor
        }
        return SecurityStatus(message: info.message, color: themedColor, icon: info.icon)
    }

}

#Preview("Free User") {
    // We wrap setup code in a closure that returns the view.
    let mockThemeManager = ThemeManager()

    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let view: some View = {
        let achievementManager = AchievementsManager(modelContext: container.mainContext)
        let mockStoreManager = EnhancedStoreManager()
        let freeProManager = ProStatusManager(storeManager: mockStoreManager)
        freeProManager.isPro = false  // not pro

        return ContentView()
            .environmentObject(freeProManager)
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
    }()
    return view
}

#Preview("Pro User") {
    let mockThemeManager = ThemeManager()

    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let view: some View = {
        let achievementManager = AchievementsManager(modelContext: container.mainContext)
        let mockStoreManager = EnhancedStoreManager()
        let proManager = ProStatusManager(storeManager: mockStoreManager, debug: true)

        return ContentView()
            .environmentObject(proManager)
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
    }()
    return view
}
