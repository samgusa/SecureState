//
//  SecurityViewModel.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SecurityViewModel: ObservableObject {
    @Published var deviceScore: Double = 15 // Out of 45
    @Published var situationalScore: Double = 15 // Out of 35
    @Published var animateScore: Bool = false
    @Published var selectedSection: SecuritySection? = nil
    @Published var showingDetails: Bool = false
    @Published var selectedTab: TabAction = .overview
    @Published var isRefreshing: Bool = false
    @Published var scrollOffset: CGFloat = 0
    @Published var lastRefreshTime = Date()
    @Published var needsAttentionComponents: Set<String> = []
    // Change when Create network Type
    @Published var networkType: String = "" // REMEMBER TO CHANGE LATER
    // Screen Recording
    @Published var isScreenBeingRecorded: Bool = false
    @Published var selectedComponentForConfirmation: SecurityComponent? = nil
    @Published var realDeviceComponents: [SecurityComponent] = []
    @Published var realComponentsLoaded: Bool = false

    // Detectors
    let screenRecordingDetector = ScreenRecordingDetector()
    let iosVersionDetector = iOSVersionDetector()
    let vpnDetector = VPNStatusDetector()
    let networkTypeDetector = NetworkTypeDetector()

    private var cancellables = Set<AnyCancellable>()

    let maxDeviceScore: Double = 55
    let maxSituationalScore: Double = 45

    var devicePercentage: Double {
        min(deviceScore / maxDeviceScore, 1.0)
    }

    var situationalPercentage: Double {
        min(situationalScore / maxSituationalScore, 1.0)
    }

    var totalScore: Double {
        deviceScore + situationalScore
    }

    var totalMaxScore: Double {
        maxDeviceScore + maxSituationalScore
    }

    var overallPercentage: Double {
        totalScore / totalMaxScore
    }

    var overallScoreColor: Color {
        SecurityConfigEnum.Level.from(percentage: situationalPercentage).data.3
    }

    var securityLevel: SecurityConfigEnum.Level {
        SecurityConfigEnum.Level.from(percentage: overallPercentage)
    }

    // Security status message based on overall score
    var securityStatus: (message: String, color: Color, icon: String) {
        let info = securityLevel.data
        return (info.0, info.1, info.2)
    }

    init() {
        setupDetectorObservations()
    }

    private func setupDetectorObservations() {
        screenRecordingDetector.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        iosVersionDetector.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        vpnDetector.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        networkTypeDetector.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

    }


    // MARK: - Computed Properties

    var situationalGradient: LinearGradient {
        let colors = SecurityConfigEnum.Level.from(percentage: situationalPercentage).data.4
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .center
        )
    }

    var deviceGradient: LinearGradient {
        let colors = SecurityConfigEnum.Level.from(percentage: devicePercentage).data.colorArr
        return LinearGradient(
            colors: colors,
            startPoint: .center,
            endPoint: .bottomTrailing
        )
    }

    func scoreColors(for percentage: Double) -> [Color] {
        switch percentage {
        case 0.8...1.0:
            return [.green, .mint]
        case 0.6..<0.8:
            return [.orange, .yellow]
        default:
            return [.red, .pink]
        }
    }

    // Security advice based on current scores
    func getSecurityAdvice() -> String {
        switch securityLevel {
        case .excellent, .good: return "Consider enabling additional security measures"
        case .moderate: return devicePercentage < situationalPercentage ?
            "Focus on device security - enable VPN and update iOS" :
            "Be cautious of your current environment - avoid public Wi-Fi"
        case .high: return "Multiple security improvements needed"
        }
    }

    // Simulate security refresh
    func performSecurityRefresh() async {
        isRefreshing = true

        // Simulate network check time
        try? await Task.sleep(for: .seconds(1.5))

        // Simulate some score changes (in real app, this would be actual security checks)
        withAnimation(.easeInOut(duration: 0.8)) {
            // Random small variations for demo
            deviceScore = max(20, min(55, deviceScore + Double.random(in: -3...3)))
            situationalScore = max(15, min(45, situationalScore + Double.random(in: -2...2)))
            animateScore.toggle()
        }

        lastRefreshTime = Date()
        isRefreshing = false
    }

    func detectScreenRecordingScore() -> Int {
        return isScreenBeingRecorded ? 0 : 5
    }

    func getRealScreenRecordingComponent() async -> SecurityComponent {
        return SecurityComponent(
            name: "Screen Recording Detection",
            score: screenRecordingDetector.getSecurityScore(),
            maxScore: 5,
            icon: screenRecordingDetector.isScreenBeingCaptured ? "eye" : "eye.slash"
        )
    }

    func getRealIOSVersionComponent() async -> SecurityComponent {
        let score = iosVersionDetector.getSecurityScore()
        let maxScore: Int = 10
        let needsConfirmation = iosVersionDetector.needsUserConfirmation()

        // determin icon based on version and user confirmation
        let icon: String
        if needsConfirmation {
            icon = "gear.badge.questionmark"
        } else if score >= 8 {
            icon = "gear.badge.checkmark"
        } else {
            icon = "gear.badge.mark"
        }

        return SecurityComponent(
            name: "iOS Version",
            score: score,
            maxScore: maxScore,
            icon: icon
        )
    }

    func getRealVPNComponent() async -> SecurityComponent {
        let score = vpnDetector.getSecurityScore()
        let maxScore = 15
        let needsConfirmation = vpnDetector.needsUserConfirmation()

        // determine icon based on VPN status and confirmation state
        let icon: String
        if needsConfirmation {
            icon = "xmark.shield"
        } else if let confirmed = vpnDetector.isUserConfirmedVPN, confirmed {
            icon = "shield.checkered"
        } else if vpnDetector.isVPNDetected {
            icon = "shield"
        } else {
            icon = "shield.slash"
        }

        return SecurityComponent(
            name: "VPN Connection",
            score: score,
            maxScore: maxScore,
            icon: icon
        )
    }

    func getRealNetworkComponent() async -> SecurityComponent {
        let score = networkTypeDetector.getSecurityScore()
        let maxScore: Int = 10
        let needsConfirmation = networkTypeDetector.needsUserConfirmation()

        // determine icon based on network type and confirmation state
        let icon: String
        if needsConfirmation {
            icon = networkTypeDetector.currentNetworkType.icon + ".badge.questionmark"
        } else if let confirmed = networkTypeDetector.isUserConfirmedSafe {
            icon = confirmed ? networkTypeDetector.currentNetworkType.icon + ".badge.checkmark" : networkTypeDetector.currentNetworkType.icon + ".badge.xmark"
        } else {
            icon = networkTypeDetector.currentNetworkType.icon
        }

        return SecurityComponent(
            name: "Network Type",
            score: score,
            maxScore: maxScore,
            icon: icon
        )
    }

    func loadRealDeviceComponents() async {
        screenRecordingDetector.checkCurrentState()
        vpnDetector.checkVPNStatus()

        try? await Task.sleep(for: .milliseconds(100))

        let screenRecordingComponent = await getRealScreenRecordingComponent()
        let iOSVersionComponent = await getRealIOSVersionComponent()
        let vpnComponent = await getRealVPNComponent()
        let networkComponent = await getRealNetworkComponent()

        await MainActor.run {
            self.realDeviceComponents = [
                vpnComponent,
                iOSVersionComponent,
                networkComponent,
                screenRecordingComponent

            ]
        }

        // Update device score to include the actual score
        let totalDeviceScore = realDeviceComponents.reduce(0, { $0 + $1.score } )
        self.deviceScore = Double(totalDeviceScore)

        self.realComponentsLoaded = true

        updateNeedsAttentionComponents()
    }

    func updateNeedsAttentionComponents() {
        var attentionSet: Set<String> = []

        // Check iOS version component
        if iosVersionDetector.needsUserConfirmation() {
            attentionSet.insert("iOS Version")
        }

        if screenRecordingDetector.isScreenBeingCaptured {
            attentionSet.insert("Screen Recording")
        }

        // Check VPN Status
        if vpnDetector.needsUserConfirmation() {
            attentionSet.insert("VPN Status")
        }

        // Check network Type
        if networkTypeDetector.needsUserConfirmation() {
            attentionSet.insert("Network Type")
        }

        needsAttentionComponents = attentionSet
    }
}

#Preview {
    ContentView()
}
