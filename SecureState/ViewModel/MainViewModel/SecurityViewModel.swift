//
//  SecurityViewModel.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import Foundation
import SwiftUI
import Combine
import SwiftData

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

    @Published var showThemePicker: Bool = false
    @Published var showUpgradeSheet: Bool = false
    @Published var badgeRefreshTrigger: Bool = false

    weak var achievementsManager: AchievementsManager?

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

    var modelContext: ModelContext?

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

    var securityLevel: SecurityConfigEnum.Level {
        SecurityConfigEnum.Level.from(percentage: overallPercentage)
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
        await MainActor.run {
            loadPersistedStatus()
        }

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

    func loadPersistedStatus() {
        guard let modelContext = modelContext else { return }

        // VPN
        if let state = PersistenceManager.loadCompleteState(
            identifier: .vpnStatus,
            context: modelContext
        ) {
            vpnDetector.isUserConfirmedVPN = state.userConfirmed
        }

        // iOS Version
        if let state = PersistenceManager.loadCompleteState(
            identifier: .iosVersion,
            context: modelContext
        ) {
            iosVersionDetector.isUserConfirmedLatest = state.userConfirmed
            iosVersionDetector.lastConfirmationDate = Date() // need to persist this too
            let id = ComponentIdentifier.iosVersion.rawValue
            let descriptor = FetchDescriptor<StoredComponent>(
                predicate: #Predicate { $0.identifier == id }
            )
            if let stored = try? modelContext.fetch(descriptor).first {
                iosVersionDetector.lastConfirmationDate = stored.lastUpdated
            }
        }

        // Device Lock
        if PersistenceManager.loadCompleteState(
            identifier: .deviceLock,
            context: modelContext
        ) != nil {
            let id = ComponentIdentifier.deviceLock.rawValue
            let descriptor = FetchDescriptor<StoredComponent>(
                predicate: #Predicate { $0.identifier == id }
            )
            if let stored = try? modelContext.fetch(descriptor).first,
               let metadataJSON = stored.metadataJSON,
               let data = metadataJSON.data(using: .utf8),
               let metadata = try? JSONDecoder().decode(DeviceLockMetadata.self, from: data) {
                deviceLockDetector.userConfirmedSixDigitPasscode = metadata.sixDigitPasscode
                deviceLockDetector.userConfirmedStrongPasscode = metadata.strongPasscode
                deviceLockDetector.userConfirmedQuickAutoLock = metadata.quickAutoLock
                deviceLockDetector.biometricAvailable = metadata.biometricAvailable ?? false
                deviceLockDetector.biometricTestPassed = metadata.biometricTestPassed ?? false
            }
        }

        // Bluetooth
        if PersistenceManager.loadCompleteState(
            identifier: .bluetoothSecurity,
            context: modelContext
        ) != nil {
            let id = ComponentIdentifier.bluetoothSecurity.rawValue
            let descriptor = FetchDescriptor<StoredComponent>(
                predicate: #Predicate { $0.identifier == id }
            )
            if let stored = try? modelContext.fetch(descriptor).first,
               let metadataJSON = stored.metadataJSON,
               let data = metadataJSON.data(using: .utf8),
               let metadata = try? JSONDecoder().decode(BluetoothMetadata.self, from: data) {
                bluetoothSecurityDetector.userEnvironmentConfirmation = metadata.environmentSafety
            }
        }

        // Environment Security
        if PersistenceManager.loadCompleteState(
            identifier: .environmentalSecurity,
            context: modelContext
        ) != nil {
            let id = ComponentIdentifier.environmentalSecurity.rawValue
            let descriptor = FetchDescriptor<StoredComponent>(
                predicate: #Predicate { $0.identifier == id }
            )
            if let stored = try? modelContext.fetch(descriptor).first,
               let metadataJSON = stored.metadataJSON,
               let data = metadataJSON.data(using: .utf8),
               let metadata = try? JSONDecoder().decode(EnvironmentalMetadata.self, from: data) {
                // Restore network trust level if on Wifi
                if environmentSecurityDetector.networkType == .wifi {
                    environmentSecurityDetector.networkTrustLevel = metadata.networkTrustLevel
                }
                // restore environment type
                environmentSecurityDetector.environmentType = metadata.environmentType
            }
        }

        // check for remembered network(current wifi)
        if environmentSecurityDetector.networkType == .wifi {
            let currentSSIDHash = environmentSecurityDetector.currentNetworkName.sha256Hex()
            let networkDescriptor = FetchDescriptor<RememberedNetwork>(
                predicate: #Predicate { $0.ssid == currentSSIDHash }
            )
            if let remembered = try? modelContext.fetch(networkDescriptor).first {
                let trustLevel: EnvironmentalSecurityDetector.NetworkTrustLevel = remembered.trustLevel == 1 ? .trusted : .isPublic
                environmentSecurityDetector.networkTrustLevel = trustLevel
            }
        }

        // check for remembered location (if we have current location)
        if let snapshot = environmentSecurityDetector.currentLocationSnapshot {
            let geohash = coarsen(snapshot.coordinate)
            let locationDescriptor = FetchDescriptor<RememberedLocation>(
                predicate: #Predicate { $0.geohash == geohash }
            )
            if let remembered = try? modelContext.fetch(locationDescriptor).first {
                if let envType = EnvironmentalSecurityDetector.EnvironmentType(rawValue: remembered.context) {
                    environmentSecurityDetector.environmentType = envType
                    environmentSecurityDetector.smartSuggestion = envType
                }
            }
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
        Haptic.tap()
        guard let context = modelContext else { return }
        let autoScore: Int
        let userScore: Int?
        let userConfirmed: Bool?
        var metadataJSON: String? = nil

        switch component.identifier {
        case .iosVersion:
            if confirmed {
                iosVersionDetector.confirmLatestVersion()
            } else {
                iosVersionDetector.confirmUpdateAvailable()
            }
            autoScore = iosVersionDetector.calculateAutoScore()
            userScore = iosVersionDetector.getSecurityScore()
            userConfirmed = iosVersionDetector.isUserConfirmedLatest
        case .vpnStatus:
            if confirmed {
                vpnDetector.confirmVPNActive()
            } else {
                vpnDetector.confirmNoVPN()
            }
            autoScore = vpnDetector.isVPNDetected ? 3 : 0
            userScore = vpnDetector.getSecurityScore()
            userConfirmed = vpnDetector.isUserConfirmedVPN

        case .environmentalSecurity:
            autoScore = environmentSecurityDetector.getNetworkScore()
            userScore = environmentSecurityDetector.getEnvironmentScore()
            userConfirmed = true

            let envMetadata = EnvironmentalMetadata(
                networkTrustLevel: environmentSecurityDetector.networkTrustLevel,
                environmentType: environmentSecurityDetector.environmentType
            )
            if let encoded = try? JSONEncoder().encode(envMetadata),
               let jsonString = String(data: encoded, encoding: .utf8) {
                metadataJSON = jsonString
            }

            // Also save network and location separately
            if environmentSecurityDetector.networkType == .wifi,
               let trustLevel = environmentSecurityDetector.networkTrustLevel {
                let ssidHash = environmentSecurityDetector.currentNetworkName.sha256Hex()
                DataStore.rememberNetwork(
                    ssid: ssidHash,
                    trustLevel: trustLevel == .trusted ? 1 : 0,
                    label: nil,
                    context: modelContext ?? context
                )
            }

            if let snapshot = environmentSecurityDetector.currentLocationSnapshot,
               let envType = environmentSecurityDetector.environmentType {
                DataStore.rememberLocation(
                    coord: snapshot.coordinate,
                    contextLabel: envType.rawValue,
                    displayName: snapshot.detectedInfo.displayName,
                    context: modelContext ?? context
                )
            }

        case .deviceLock:
            // Device lock saves after questions are answered
            autoScore = deviceLockDetector.getSecurityScore()
            userScore = nil
            userConfirmed = nil


            // create metadata JSON
            let metadata = DeviceLockMetadata(
                sixDigitPasscode: deviceLockDetector.userConfirmedSixDigitPasscode,
                strongPasscode: deviceLockDetector.userConfirmedStrongPasscode,
                quickAutoLock: deviceLockDetector.userConfirmedQuickAutoLock,
                biometricAvailable: deviceLockDetector.biometricAvailable,
                biometricTestPassed: deviceLockDetector.biometricTestPassed
            )

            if let encoded = try? JSONEncoder().encode(metadata),
               let jsonString = String(data: encoded, encoding: .utf8) {
                metadataJSON = jsonString
            }

        case .bluetoothSecurity:
            // Bluetooth only saves if enabled with confirmation
            if bluetoothSecurityDetector.bluetoothEnabled {
                autoScore = bluetoothSecurityDetector.calculateBaseScore()
                userScore = bluetoothSecurityDetector.getSecurityScore()
                userConfirmed = bluetoothSecurityDetector.userEnvironmentConfirmation != nil

                let btMetadata = BluetoothMetadata(
                    environmentSafety: bluetoothSecurityDetector.userEnvironmentConfirmation
                )
                if let encoded = try? JSONEncoder().encode(btMetadata),
                   let jsonString = String(data: encoded, encoding: .utf8) {
                    metadataJSON = jsonString
                }

            } else {
                // Bluetooth disabled = max score, no persistence needed
                return
            }
        default:
            return
        }

        // Track: User viewed this component
        achievementsManager?.trackComponentViewed(component.identifier.rawValue)

        // Track VPN Confirmation
        if component.identifier == .vpnStatus && confirmed {
            achievementsManager?.trackVPNConfirmed()
        }

        // Save persistence
        PersistenceManager.saveComponentState(
            identifier: component.identifier,
            autoScore: autoScore,
            userScore: userScore ?? autoScore,
            userConfirmed: userConfirmed,
            maxScore: component.maxScore,
            metadataJSON: metadataJSON,
            context: modelContext ?? context
        )

        updateSingleComponent(identifier: component.identifier)
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
