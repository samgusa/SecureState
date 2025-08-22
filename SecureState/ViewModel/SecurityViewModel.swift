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
    @Published var deviceScore: Double = 0 // Out of 55
    @Published var situationalScore: Double = 0 // Out of 45
    @Published var animateScore: Bool = false
    @Published var selectedSection: SecuritySection? = nil

    @Published var selectedTab: TabAction = .overview
    @Published var isRefreshing: Bool = false
    @Published var scrollOffset: CGFloat = 0
    @Published var lastRefreshTime = Date()

    @Published var needsAttentionComponents: Set<String> = []
    // Change when Create network Type
    @Published var networkType: String = ""
    @Published var networkName: String = ""
    // Screen Recording
    @Published var isScreenBeingRecorded: Bool = false
    @Published var selectedComponentForConfirmation: SecurityComponent? = nil
    @Published var realComponentsLoaded: Bool = false

    // Components
    @Published var realDeviceComponents: [SecurityComponent] = []
    @Published var realSituationalComponents: [SecurityComponent] = []

    @Published var refreshCooldown: TimeInterval = 5.0 // 5 Seconds

    // Device Detectors
    let screenRecordingDetector = ScreenRecordingDetector()
    let iosVersionDetector = iOSVersionDetector()
    let vpnDetector = VPNStatusDetector()
    let networkTypeDetector = NetworkTypeDetector()

    // Situational Detectors
    let enhancedLocationContextDetector = EnhancedLocationContextDetector()
    let nearbyDeviceExposureDetector = NearbyDeviceExposureDetector()
    let networkSecurityDetector = NetworkSecurityDetector()
    let timeBasedRiskDetector = TimeBasedRiskDetector()

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

    func detectScreenRecordingScore() -> Int {
        return isScreenBeingRecorded ? 0 : 5
    }

    // MARK: Device Components
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
            icon = "gear.badge.xmark"
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

    // MARK: Situational Components

    func getRealBluetoothComponent() async -> SecurityComponent {
        let score = nearbyDeviceExposureDetector.getSecurityScore()
        let maxScore = 5
        let needsConfirmation = nearbyDeviceExposureDetector.needsUserConfirmation()

        let icon: String
        if needsConfirmation {
            icon = "questionmark.circle"
        } else if score >= 4 {
            icon = "antenna.radiowaves.left.and.right.slash"
        } else if score >= 3 {
            icon = "headphones"
        } else {
            icon = "exclamationmark.triangle"
        }

        return SecurityComponent(
            name: "Nearby Device Exposure",
            score: score,
            maxScore: maxScore,
            icon: icon
        )
    }

    func getRealTimeBasedRiskComponent() async -> SecurityComponent {
        let score = timeBasedRiskDetector.getSecurityScore()
        let maxScore = 5
        let riskLevel = timeBasedRiskDetector.currentTimeRisk

        return SecurityComponent(
            name: "Time-based Risk",
            score: score,
            maxScore: maxScore,
            icon: riskLevel.icon
        )
    }

    func getRealLocationComponent() -> SecurityComponent {
        let score = enhancedLocationContextDetector.getSecurityScore()
        let maxScore: Int = 15

        let icon: String
        if let selectedContext = enhancedLocationContextDetector.userSelectedContext {
            icon = selectedContext.icon
        } else if !enhancedLocationContextDetector.hasLocationPermission {
            icon = "location.slash"
        } else {
            icon = "location.circle"
        }

        return SecurityComponent(
            name: "Location Context",
            score: score,
            maxScore: maxScore,
            icon: icon
        )
    }

    func getRealNetworkSecurityComponent() async -> SecurityComponent {
        let score = networkSecurityDetector.getSecurityScore()
        let maxScore = 20
        let needsConfirmation = networkSecurityDetector.needsUserConfirmation()

        let icon: String
        if needsConfirmation {
            icon = "network.slash"
        } else if score >= 18 {
            icon = "shield.lefthalf.filled"
        } else if score >= 10 {
            icon = "network"
        } else {
            icon = "wifi.exclamationmark"
        }

        return SecurityComponent(
            name: "Network Security",
            score: score,
            maxScore: maxScore,
            icon: icon
        )
    }

    // Simulate security refresh
    func performSecurityRefresh() async {
        // Prevent too frequent refreshes
        let now = Date()
        if now.timeIntervalSince(lastRefreshTime) < refreshCooldown {
            print("Refresh cooldown active, skipping refresh")
            return
        }

        isRefreshing = true
        lastRefreshTime = now

        // Refreshing detectors (no location-heavy operations here)
        screenRecordingDetector.checkCurrentState()
        vpnDetector.checkVPNStatus()
        networkTypeDetector.checkNetworkType()
        timeBasedRiskDetector.checkCurrentTime()
        nearbyDeviceExposureDetector.checkCurrentState()

        // Only do location check if we haven't done one recently AND we have permission
        if enhancedLocationContextDetector.hasLocationPermission && now.timeIntervalSince(enhancedLocationContextDetector.lastLocationUpdate) > 30.0 {
            enhancedLocationContextDetector.permissionLocationSnapshot()

            // short wait for location update, but dont block too long
            for _ in 0..<10 { // 1 second max
                if !enhancedLocationContextDetector.isLocationRequestInProgress {
                    break
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
        }

        // Update location-dependant components
        nearbyDeviceExposureDetector.updateLocationContext(isPublic: enhancedLocationContextDetector.isInPublicSpace)

        // Update components
        let updateDeviceComponents = await loadDeviceComponents()
        let updateSituationComponents = await loadSituationComponents()

        await MainActor.run {
            // Update device components
            for component in updateDeviceComponents {
                if let existingIndex = realDeviceComponents.firstIndex(where: { $0.name == component.name }) {
                    realDeviceComponents[existingIndex] = component
                }
            }
            // Update situation components
            for component in updateSituationComponents {
                if let existingIndex = realSituationalComponents.firstIndex(where: { $0.name == component.name }) {
                    realSituationalComponents[existingIndex] = component
                }
            }

            // recalculate scores
            let totalDeviceScore = realDeviceComponents.reduce(0) { $0 + $1.score }
            let totalSituationScore = realSituationalComponents.reduce(0) { $0 + $1.score }

            withAnimation(.easeInOut(duration: 0.8)) {
                self.deviceScore = Double(totalDeviceScore)
                self.situationalScore = Double(totalSituationScore)
            }
            updateNeedsAttentionComponents()
        }
        isRefreshing = false
    }

    func loadRealComponents() async {
        screenRecordingDetector.checkCurrentState()
        vpnDetector.checkVPNStatus()
        networkTypeDetector.checkNetworkType()
        timeBasedRiskDetector.checkCurrentTime()
        nearbyDeviceExposureDetector.checkCurrentState()

        // Only do initial location check if we have permission
        if enhancedLocationContextDetector.hasLocationPermission {
            enhancedLocationContextDetector.permissionLocationSnapshot()

            // Give location detection reasonable time, but dont block
            for _ in 0..<15 { // 1.5 seconds max wait
                if !enhancedLocationContextDetector.isLocationRequestInProgress {
                    break
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
        }

        nearbyDeviceExposureDetector.updateLocationContext(isPublic: enhancedLocationContextDetector.isInPublicSpace)


        let deviceComponents = await loadDeviceComponents()
        let situationComponents = await loadSituationComponents()

        await MainActor.run {
            self.realDeviceComponents = deviceComponents
            self.realSituationalComponents = situationComponents

            let totalDeviceScore = realDeviceComponents.reduce(0) { $0 + $1.score }
            let totalSituationalScore = realSituationalComponents.reduce(0) { $0 + $1.score }

            self.deviceScore = Double(totalDeviceScore)
            self.situationalScore = Double(totalSituationalScore)
            self.realComponentsLoaded = true

            updateNeedsAttentionComponents()
        }
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

        // Check network Security
        if networkSecurityDetector.needsUserConfirmation() {
            attentionSet.insert("Network Security")
        }

        if enhancedLocationContextDetector.needsUserContextSelection() {
            attentionSet.insert("Location Context")
        }

        if timeBasedRiskDetector.currentTimeRisk == .high {
            attentionSet.insert("Time-based Risk")
        }

        if nearbyDeviceExposureDetector.needsUserConfirmation() {
            attentionSet.insert("Nearby Device Exposure")
        }

        needsAttentionComponents = attentionSet
    }

    func handleNetworkSecurityConfirmation(_ confirmed: Bool) {
        if confirmed {
            networkSecurityDetector.confirmedNetworkTrusted()
        } else {
            networkSecurityDetector.confirmedNetworkPublic()
        }

        Task {
            let updatedNetworkComponent = await getRealNetworkSecurityComponent()
            await MainActor.run {
                // find and update the wifi component
                if let index = realSituationalComponents.firstIndex(where: { $0.name == "Network Security "}) {
                    realSituationalComponents[index] = updatedNetworkComponent
                }

                // Recalculate situational score
                let totalSituationalScore = realSituationalComponents.reduce(0) { $0 + $1.score }
                self.situationalScore = Double(totalSituationalScore)

                // Update attention component
                updateNeedsAttentionComponents()
            }
        }
    }

    func handleComponentConfirmation(component: SecurityComponent, confirmed: Bool) {
        switch component.name {
        case "iOS Version":
            if confirmed {
                iosVersionDetector.confirmlatestVersion()
            } else {
                iosVersionDetector.confirmUpdateAvailable()
            }
        case "VPN Status":
            if confirmed {
                vpnDetector.confirmVPNActive()
            } else {
                vpnDetector.confirmNoVPN()
            }
        case "Network Type":
            if confirmed {
                networkTypeDetector.confirmNetworkSafe()
            } else {
                networkTypeDetector.confirmNetworkUnsafe()
            }
        case "Network Security":
            handleNetworkSecurityConfirmation(confirmed)
            return

        case "Location Context":
            print("Location context confirmed - refreshing components")
            break

        case "Nearby Device Exposure":
            if confirmed {
                nearbyDeviceExposureDetector.confirmAccessoryUse()
            } else {
                nearbyDeviceExposureDetector.confirmedNoAccesorryUse()
            }
        default:
            break
        }
        // update the attention components and refresh scores
        Task {
            await refreshComponentsAfterConfirmation()
        }
    }

    // Update the onAppear Logic
    func setupInitialState() {
        animateScore = false

        if !realComponentsLoaded {
            Task {
                // set up location permissions first if needed
                if enhancedLocationContextDetector.locationPermissionStatus == .notDetermined {
                    enhancedLocationContextDetector.requestLocationPermission()

                    // Get permission request time to complete
                    try? await Task.sleep(for: .milliseconds(500))
                }
                await loadRealComponents()

                // Trigger animation after components are loaded
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animateScore = true
                    }
                }
            }
        } else {
            // If components already loaded, just trigger animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.animateScore = true
                }
            }
        }
        // Initial check for components needing attention
        updateNeedsAttentionComponents()
    }

    // Helper functions to load components in parallel
    private func loadDeviceComponents() async -> [SecurityComponent] {
        async let screenRecordingComponent = getRealScreenRecordingComponent()
        async let iOSVersionComponent = getRealIOSVersionComponent()
        async let vpnComponent = getRealVPNComponent()
        async let networkComponent = getRealNetworkComponent()

        return await [
            vpnComponent,
            iOSVersionComponent,
            networkComponent,
            screenRecordingComponent
        ]
    }

    private func loadSituationComponents() async -> [SecurityComponent] {
        async let networkSecurityComponent = getRealNetworkSecurityComponent()
        async let enhancedLocationContextComponent = getRealLocationComponent()
        async let timeBasedRiskComponent = getRealTimeBasedRiskComponent()
        async let bluetoothComponent = getRealBluetoothComponent()

        return await [
            networkSecurityComponent,
            enhancedLocationContextComponent,
            timeBasedRiskComponent,
            bluetoothComponent
        ]

    }

    func refreshComponentsAfterConfirmation() async {
        // Update location context for nearby device detector
        nearbyDeviceExposureDetector.updateLocationContext(isPublic: enhancedLocationContextDetector.isInPublicSpace)

        // Reload components
        let updateDeviceComponents = await loadDeviceComponents()
        let updateSituationComponents = await loadSituationComponents()

        await MainActor.run {
            // Update device components
            for component in updateDeviceComponents {
                if let existingIndex = realDeviceComponents.firstIndex(where: { $0.name == component.name }) {
                    realDeviceComponents[existingIndex] = component
                }
            }

            for component in updateSituationComponents {
                if let existingIndex = realSituationalComponents.firstIndex(where: { $0.name == component.name }) {
                    realSituationalComponents[existingIndex] = component
                }
            }

            // Recalculate scores with animation
            let totalDeviceScore = realDeviceComponents.reduce(0) { $0 + $1.score }
            let totalSituationScore = realSituationalComponents.reduce(0) { $0 + $1.score }

            withAnimation(.easeInOut(duration: 0.8)) {
                self.deviceScore = Double(totalDeviceScore)
                self.situationalScore = Double(totalSituationScore)
            }

            // Update attention components
            updateNeedsAttentionComponents()
        }
    }

}

#Preview {
    ContentView()
}
