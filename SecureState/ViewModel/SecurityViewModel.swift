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

    @Published var needsAttentionComponents: Set<ComponentIdentifier> = []
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
    let deviceLockDetector = DeviceLockSecurityDetector()

    // Situational Detectors
    let enhancedLocationContextDetector = EnhancedLocationContextDetector() // O
    let networkSecurityDetector = NetworkSecurityDetector()
    let timeBasedRiskDetector = TimeBasedRiskDetector()
    let bluetoothSecurityDetector = EnhancedBluetoothSecurityDetector()
    let environmentSecurityDetector = EnvironmentalSecurityDetector()

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
    func getRealVPNComponent() async -> SecurityComponent {
        let score = vpnDetector.getSecurityScore()
        let maxScore = 20
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
            identifier: .vpnStatus,
            score: score,
            maxScore: maxScore,
            icon: icon
        )
    }

    func getRealIOSVersionComponent() async -> SecurityComponent {
        let score = iosVersionDetector.getSecurityScore()
        let maxScore: Int = 15
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
            identifier: .iosVersion,
            score: score,
            maxScore: maxScore,
            icon: icon
        )
    }

    func getRealScreenRecordingComponent() async -> SecurityComponent {
        return SecurityComponent(
            identifier: .screenRecording,
            score: screenRecordingDetector.getSecurityScore(),
            maxScore: 5,
            icon: screenRecordingDetector.isScreenBeingCaptured ? "eye" : "eye.slash"
        )
    }

    func getRealDeviceLockComponent() async -> SecurityComponent {
        let score = deviceLockDetector.getSecurityScore()
        let maxScore = 15
        var icon: String
        if deviceLockDetector.biometricAvailable && deviceLockDetector.biometricTestPassed {
            icon = deviceLockDetector.biometricType == .faceID ? "faceid" : "touchid"
        } else if deviceLockDetector.biometricAvailable {
            icon = "faceid"
        } else if deviceLockDetector.passcodeSet {
            icon = "lock.fill"
        } else {
            icon = "lock.slash.fill"
        }

        return SecurityComponent(
            identifier: .deviceLock,
            score: score,
            maxScore: maxScore,
            icon: icon
        )
    }

    // MARK: Situational Components

    func getRealBluetoothComponent() -> SecurityComponent {
        let score = bluetoothSecurityDetector.getSecurityScore()
        let maxScore: Int = 15

        let icon: String
        if !bluetoothSecurityDetector.bluetoothEnabled {
            // Bluetooth disabled - show as secure
            icon = "antenna.radiowaves.left.and.right.slash"
        } else if bluetoothSecurityDetector.needsUserConfirmation() {
            // Needs attention - either no scan or no user confirmation
            icon = "antenna.radiowaves.left.and.right.circle.fill"
        } else {
            // all good
            icon = "antenna.radiowaves.left.and.right"
        }

        return SecurityComponent(
            identifier: .bluetoothSecurity,
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
            identifier: .timeBasedRisk,
            score: score,
            maxScore: maxScore,
            icon: riskLevel.icon
        )
    }

    func getRealEnvironmentalSecurityComponent() async -> SecurityComponent {
        let score = environmentSecurityDetector.getEnvironmentScore()
        let maxScore: Int = 25

        let icon: String
        if environmentSecurityDetector.needsUserConfirmation() {
            icon = "shield.lefthalf.filled.trianglebadge.exclamationmark"
        } else {
            let percentage = Double(score) / Double(maxScore)
            if percentage >= 0.8 {
                icon = "shield.lefthalf.filled"
            } else if percentage >= 0.5 {
                icon = "shield.lefthalf.filled.trianglebadge.exclamationmark"
            } else {
                icon = "shield.slash"
            }
        }
        return SecurityComponent(
            identifier: .environmentalSecurity,
            score: score,
            maxScore: maxScore,
            icon: icon
        )
    }

    func getSingleUpdatedComponent(identifier: ComponentIdentifier) async -> SecurityComponent {
        switch identifier {
        case .screenRecording:
            return await getRealScreenRecordingComponent()
        case .iosVersion:
            return await getRealIOSVersionComponent()
        case .vpnStatus:
            return await getRealVPNComponent()
        case .deviceLock:
            return await getRealDeviceLockComponent()
        case .environmentalSecurity:
            return await getRealEnvironmentalSecurityComponent()
        case .timeBasedRisk:
            return await getRealTimeBasedRiskComponent()
        case .bluetoothSecurity:
            return getRealBluetoothComponent()
        }
    }

    // Simulate security refresh
    func performSecurityRefresh() async {
        // Prevent too frequent refreshes
        let now = Date()
        if now.timeIntervalSince(lastRefreshTime) < refreshCooldown {
            return
        }

        isRefreshing = true
        lastRefreshTime = now

        // Refreshing detectors (no location-heavy operations here)
        screenRecordingDetector.checkCurrentState()
        vpnDetector.checkVPNStatus()
        timeBasedRiskDetector.checkCurrentTime()
        deviceLockDetector.checkDeviceLockCapabilities()
        bluetoothSecurityDetector.checkBluetoothStatus()


        // Only do location check if we haven't done one recently AND we have permission
        if environmentSecurityDetector.hasLocationPermission && now.timeIntervalSince(environmentSecurityDetector.lastLocationUpdate) > 30.0 {
            environmentSecurityDetector.performLocationSnapshot()
        }

        // Short wait for location update
        for _ in 0..<10 {
            if !environmentSecurityDetector.isLocationRequestInProgress {
                break
            }
            try? await Task.sleep(for: .milliseconds(100))
        }

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
        timeBasedRiskDetector.checkCurrentTime()
        bluetoothSecurityDetector.checkCurrentState()
        deviceLockDetector.checkDeviceLockCapabilities()

        // Only do initial location check if we have permission
        if environmentSecurityDetector.hasLocationPermission {
            environmentSecurityDetector.performLocationSnapshot()

            // give location detection reasonable time
            for _ in 0..<15 {
                if !environmentSecurityDetector.isLocationRequestInProgress {
                    break
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
        }

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
        var attentionSet: Set<ComponentIdentifier> = []

        // Check iOS version component
        if iosVersionDetector.needsUserConfirmation() {
            attentionSet.insert(.iosVersion)
        }

        if screenRecordingDetector.isScreenBeingCaptured {
            attentionSet.insert(.screenRecording)
        }

        // Check VPN Status
        if vpnDetector.needsUserConfirmation() {
            attentionSet.insert(.vpnStatus)
        }

        // Environmental Security check
        if environmentSecurityDetector.needsUserConfirmation() {
            attentionSet.insert(.environmentalSecurity)
        }

        if timeBasedRiskDetector.currentTimeRisk == .high {
            attentionSet.insert(.timeBasedRisk)
        }

        if deviceLockDetector.needsUserConfirmation() {
            attentionSet.insert(.deviceLock)
        }

        if bluetoothSecurityDetector.needsUserConfirmation() {
            attentionSet.insert(.bluetoothSecurity)
        }

        needsAttentionComponents = attentionSet
    }

    func handleComponentConfirmation(component: SecurityComponent, confirmed: Bool) {
        switch component.identifier {
        case .iosVersion:
            if confirmed {
                iosVersionDetector.confirmLatestVersion()
            } else {
                iosVersionDetector.confirmUpdateAvailable()
            }
            updateSingleComponent(identifier: .iosVersion)

        case .vpnStatus:
            if confirmed {
                vpnDetector.confirmVPNActive()
            } else {
                vpnDetector.confirmNoVPN()
            }
            updateSingleComponent(identifier: .vpnStatus)

        case .environmentalSecurity:
            updateSingleComponent(identifier: .environmentalSecurity)

        case .deviceLock:
            updateSingleComponent(identifier: .deviceLock)

        case .bluetoothSecurity:
            updateSingleComponent(identifier: .bluetoothSecurity)

        default:
            break
        }
    }

    func updateSingleComponent(identifier: ComponentIdentifier) {
        Task {

            let updatedComponent = await getSingleUpdatedComponent(identifier: identifier)

            await MainActor.run {
                if identifier.isDeviceComponent {
                    if let index = realDeviceComponents.firstIndex(where: { $0.identifier == identifier }) {
                        realDeviceComponents[index] = updatedComponent
                    }

                    // recalculate only device score
                    let totalDeviceScore = realDeviceComponents.reduce(0) { $0 + $1.score }
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.deviceScore = Double(totalDeviceScore)
                    }
                } else {
                    if let index = realSituationalComponents.firstIndex(where: { $0.identifier == identifier }) {
                        realSituationalComponents[index] = updatedComponent
                    }
                    // recalculate only situational score
                    let totalSituationalScore = realSituationalComponents.reduce(0) { $0 + $1.score }
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.situationalScore = Double(totalSituationalScore)
                    }
                }
                updateNeedsAttentionComponents()
            }
        }
    }

    // Update the onAppear Logic
    func setupInitialState() {
        animateScore = false

        if !realComponentsLoaded {
            Task {
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
        async let deviceLockComponent = getRealDeviceLockComponent()

        return await [
            vpnComponent,
            iOSVersionComponent,
            screenRecordingComponent,
            deviceLockComponent
        ]
    }

    private func loadSituationComponents() async -> [SecurityComponent] {
        async let environmentalComponent = getRealEnvironmentalSecurityComponent()
        async let timeBasedRiskComponent = getRealTimeBasedRiskComponent()
        async let bluetoothComponent = getRealBluetoothComponent()

        return await [
            environmentalComponent,
            timeBasedRiskComponent,
            bluetoothComponent
        ]
    }

}

#Preview {
    ContentView()
}
