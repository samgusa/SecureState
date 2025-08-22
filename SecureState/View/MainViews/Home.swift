//
//  Home.swift
//  SecureState
//
//  Created by Sam Greenhill on 5/27/25.
//

import SwiftUI

struct Home: View {

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
                                securityStatusIcon: secureState.securityStatus.icon,
                                securityStatusColor: secureState.securityStatus.color,
                                securityStatusMessage: secureState.securityStatus.message,
                                overallPercentage: secureState.overallPercentage) {
                                    await secureState.performSecurityRefresh()
                                }
                                .id("header")

                            // Main Visualization
                            SScoreView(
                                animateScore: $secureState.animateScore,
                                situationalPercentage: secureState.situationalPercentage,
                                situationalGradient: secureState.situationalGradient,
                                devicePercentage: secureState.devicePercentage,
                                deviceGradient: secureState.deviceGradient,
                                selectedSection: $secureState.selectedSection,
                                situationalScore: $secureState.situationalScore,
                                deviceScore: $secureState.deviceScore
                            )
                            .frame(width: 320, height: 400)
                            .id("visualization")

                            // Overall Score Card with Status Message
                            ScoreCardView(
                                animateScore: $secureState.animateScore,
                                overallPercentage: secureState.overallPercentage,
                                overallScoreColor: secureState.overallScoreColor,
                                securityStatusMessage: secureState.securityStatus.message,
                                securityStatusColor: secureState.securityStatus.color,
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
                                maxDeviceScore: secureState.maxDeviceScore,
                                devicePercentage: secureState.devicePercentage,
                                maxSituationalScore: secureState.maxSituationalScore,
                                situationalPercentage: secureState.situationalPercentage,
                                scoreColors: [secureState.scoreColors(for: secureState.devicePercentage).first ?? .gray, secureState.scoreColors(for: secureState.situationalPercentage).first ?? .gray],
                                onConfirm: { component, confirmed in
                                    secureState
                                        .handleComponentConfirmation(
                                            component: component,
                                            confirmed: confirmed
                                        )
                                },
                                networkType: secureState.networkType,
                                networkName: secureState.networkName,
                                enhancedLocationContextDetector: secureState.enhancedLocationContextDetector,
                                realDeviceComponents: secureState.realDeviceComponents,
                                realSituationalComponents: secureState.realSituationalComponents
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
                secureState.setupInitialState()
            }
            .refreshable {
                await secureState.performSecurityRefresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: .locationContextSelected)) { _ in
                secureState.nearbyDeviceExposureDetector.updateLocationContext(isPublic: secureState.enhancedLocationContextDetector.isInPublicSpace)
                Task {
                    await secureState.performSecurityRefresh()
                }
            }
        }
    }

    var fixedNotificationReceiver: some View {
        EmptyView()
            .onReceive(NotificationCenter.default.publisher(for: .locationContextSelected), perform: { notification in
                print("Received location context selection notification")

                // Update nearby device detector with new location context
                secureState.nearbyDeviceExposureDetector.updateLocationContext(isPublic: secureState.enhancedLocationContextDetector.isInPublicSpace)

                // Refresh all component
                Task {
                    await secureState.refreshComponentsAfterConfirmation()
                }

            })
    }
}

#Preview {
    ContentView()
}
