//
//  Extension+Home.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/24/25.
//

import Foundation
import SwiftUI
import SwiftData


extension Home {
    var contentScrollLayer: some View {
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
            .onChange(of: secureState.selectedTab) { _, newTab in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo("content", anchor: .top)
                }

                if newTab != .overview {
                    withAnimation {
                        secureState.selectedSection = nil
                    }
                }
            }
        }
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
