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
    @StateObject private var secureState = SecurityViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 24) {

                            fixedNotificationReceiver

                            // Header Section with Auto-refresh
                            HeaderView(
                                isRefreshing: secureState.isRefreshing,
                                lastRefreshTime: secureState.lastRefreshTime,
                                securityStatusIcon: securityStatus.icon,
                                securityStatusColor: securityStatus.color,
                                securityStatusMessage: securityStatus.message,
                                overallPercentage: secureState.overallPercentage) {
                                    await secureState.performSecurityRefresh()
                                }
                                .id("header")
//
//                            // Main Visualization
                            SScoreView(
                                animateScore: $secureState.animateScore,
                                situationalPercentage: secureState.situationalPercentage,
                                situationalGradient: themedSituationalGradient,
                                devicePercentage: secureState.devicePercentage,
                                deviceGradient: themedDeviceGradient,
                                selectedSection: $secureState.selectedSection,
                                selectedTab: $secureState.selectedTab,
                                situationalScore: $secureState.situationalScore,
                                deviceScore: $secureState.deviceScore
                            )
                            .frame(width: 320, height: 400)
                            .id("visualization")

                            // Overall Score Card with Status Message
                            ScoreCardView(
                                animateScore: $secureState.animateScore,
                                badgeRefreshTrigger: $secureState.badgeRefreshTrigger,
                                overallPercentage: secureState.overallPercentage,
                                overallScoreColor: overallScoreColor,
                                securityStatusMessage: securityStatus.message,
                                securityStatusColor: securityStatus.color,
                                totalScore: secureState.totalScore,
                                totalMaxScore: Int(secureState.totalMaxScore),
                                securityAdvice: secureState.getSecurityAdvice()
                            )
                            .id("scorecard")

                            // Current tab content
                            CurrentTabContent(
                                selectedSection: $secureState.selectedSection,
                                deviceScore: $secureState.deviceScore,
                                situationalScore: $secureState.situationalScore,
                                selectedTab: $secureState.selectedTab,
                                selectedComponentForConfirmation: $secureState.selectedComponentForConfirmation,
                                needsAttentionComponents: $secureState.needsAttentionComponents,
                                badgeRefreshTrigger: $secureState.badgeRefreshTrigger,
                                maxDeviceScore: secureState.maxDeviceScore,
                                devicePercentage: secureState.devicePercentage,
                                maxSituationalScore: secureState.maxSituationalScore,
                                situationalPercentage: secureState.situationalPercentage,
                                scoreColors: [scoreColors(for: secureState.devicePercentage).first ?? .gray, scoreColors(for: secureState.situationalPercentage).first ?? .gray],
                                onConfirm: { component, confirmed in
                                    secureState
                                        .handleComponentConfirmation(component: component, confirmed: true)
                                },
                                networkName: secureState.networkName,
                                deviceLockDetector: secureState.deviceLockDetector,
                                bluetoothSecurityDetector: secureState.bluetoothSecurityDetector,
                                environmentalSecurityDetector: secureState.environmentSecurityDetector,
                                vpnDetector: secureState.vpnDetector,
                                screenRecordingDetector: secureState.screenRecordingDetector,
                                iosVersionDetector: secureState.iosVersionDetector,
                                timeBasedDetector: secureState.timeBasedRiskDetector,
                                realDeviceComponents: secureState.realDeviceComponents,
                                realSituationalComponents: secureState.realSituationalComponents,
                                loadRealComponents: {
                                    Task {
                                        await secureState.loadRealComponents()

                                        await MainActor.run {
                                            secureState.animateScore = false
                                        }
                                        try? await Task.sleep(for: .milliseconds(100))
                                        await MainActor.run {
                                            withAnimation(.easeInOut(duration: 0.8)) {
                                                secureState.animateScore = true
                                            }
                                        }
                                    }
                                },
                                onComponentUpdate: { identifier, confirmed in
                                    if let component = (secureState.realDeviceComponents + secureState.realSituationalComponents).first(where: { $0.identifier == identifier }) {
                                        secureState.handleComponentConfirmation(component: component, confirmed: confirmed)
                                    }
                                }
                            )
                            .id("content")
                            .padding(.bottom, 100)
                        }
                        .padding()
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                            }
                        )
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        secureState.scrollOffset = value
                    }
                    .onChange(of: secureState.selectedSection) { _, newSelection in
                        if newSelection != nil {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                proxy.scrollTo("content" ,anchor: .top)
                            }
                        }
                    }
                }

                if proManager.isPro {
                    FloatingThemePickerButton(showThemePicker: $secureState.showThemePicker)
                }
                VStack {
                    Spacer()
                    FloatingTabBarView(selectedTab: $secureState.selectedTab)
                        .padding(.horizontal)
                        .padding(.bottom, 34)
                }
            }
            .navigationTitle("Secure State")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                secureState.modelContext = modelContext
                secureState.achievementsManager = achievementsManager
                secureState.setupInitialState()
            }
            .refreshable {
                await secureState.performSecurityRefresh()
            }
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
        .onChange(of: achievementsManager.selectedBadge) { oldValue, newValue in
            withAnimation(.spring()) { }
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
