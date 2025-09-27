//
//  EnvironmentalSecurityDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/24/25.
//

import Foundation
import SwiftUI
import Network
import NetworkExtension
import MapKit
import CoreLocation
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork

class EnvironmentalSecurityDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Published properties
    @Published var networkType: NetworkType = .unknown
    @Published var networkTrustLevel: NetworkTrustLevel? = nil
    @Published var locationContext: LocationSecurityContext? = nil
    @Published var environmentType: EnvironmentType? = nil
    @Published var currentNetworkName: String = ""

    @Published var currentLocationSnapshot: LocationSnapshot?
    @Published var detectionConfidence: DetectionConfidence = .failed("")
    @Published var lastLocationUpdate: Date = Date()
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationRequestInProgress: Bool = false
    @Published var locationError: String? = nil
    @Published var smartSuggestion: EnvironmentType?

    // User override states
    @Published var userConfirmedNetworkType: Bool? = nil
    @Published var userSelectedEnvironment: EnvironmentType? = nil
    @Published var userConfirmedEnvironmentSafety: Bool? = nil

    // MARK: Private Properties
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "EnvironmentalMonitor")
    private let locationManager = CLLocationManager()
    private var locationTimer: Timer?
    private let locationTimeout: TimeInterval = 8.0
    private let maxScore: Int = 25

    // Rate Limiting
    private let lastGeocodingRequest: Date = Date.distantPast
    private let geocodingRateLimit: TimeInterval = 2.0
    private var environmentContextCache: [CachedEnvironmentContext] = []
    private let cacheRadius: CLLocationDistance = 100.0 // 100 meters
    private let cacheMaxAge: TimeInterval = 86400.0

    private var networkMemory: [NetworkContext] = []

    // MARK: DataModel
    struct LocationSnapshot {
        let coordinate: CLLocationCoordinate2D
        let accuracy: CLLocationAccuracy
        let timestamp: Date
        let detectedInfo: DetectedLocationInfo

        var isAccurate: Bool { accuracy <= 100.0 }
    }

    struct NetworkContext {
        let ssidHash: String // Hased SSID
        let trustLevel: NetworkTrustLevel
        let locationHash: String?
        let timeStamp: Date
        let userLabel: String?
    }

    struct DetectedLocationInfo {
        let primaryName: String?            // Main identifier (business name, landmark)
        let streetAddress: String?          // Street number + street name
        let neighborhood: String?           // Sublocality or area
        let areasOfInterest: [String]       // Nearby POIs
        let rawPlacemark: CLPlacemark?      // Full placemark for debugging

        var displayName: String {
            if let primaryName = primaryName, !primaryName.isEmpty {
                return primaryName
            }

            if let streetAddress = streetAddress, !streetAddress.isEmpty {
                return streetAddress
            }
            return "Unknown Location"
        }

        var detailDescription: String {
            var components: [String] = []
            if let streetAddress = streetAddress { components.append(streetAddress) }
            if let neighborhood = neighborhood { components.append(neighborhood) }
            if !areasOfInterest.isEmpty {
                components.append("Near: " + areasOfInterest.prefix(2).joined(separator: ", "))
            }
            return components.joined(separator: " • ")
        }
    }

    enum DetectionConfidence {
        case high(String)           // Specific business/landmark detected
        case medium(String)         // Street address with context
        case low(String)            // Basic location components only
        case failed(String)         // No usable location data

        var level: String {
            switch self {
            case .high: return "High"
            case .medium: return "Medium"
            case .low: return "Low"
            case .failed: return "Failed"
            }
        }

        var description: String {
            switch self {
            case .high(let details): return details
            case .medium(let details): return details
            case .low(let details): return details
            case .failed(let details): return details
            }
        }

        var color: Color {
            switch self {
            case .high: return .green
            case .medium: return .blue
            case .low: return .orange
            case .failed: return .red
            }
        }
    }

    struct CachedEnvironmentContext {
        let coordinate: CLLocationCoordinate2D
        let environmentType: EnvironmentType
        let timeStamp: Date
        let displayName: String
    }

    enum NetworkType {
        case cellular, wifi, unknown

        var baseScore: Int {
            switch self {
            case .cellular: return 15
            case .wifi: return 8 // default for unknown wifi
            case .unknown: return 5
            }
        }

        var description: String {
            switch self {
            case .cellular: return "Cellular Connection"
            case .wifi: return "Wi-Fi Connection"
            case .unknown: return "Unknown Connection"
            }
        }
    }

    enum NetworkTrustLevel {
        case trusted, isPublic, unknown

        var scoreModifier: Int {
            switch self {
            case .trusted: return 4     // Wifi: 8 + 4 = 12
            case .isPublic: return -5   // Wifi 8 - 5 = 3
            case .unknown: return 0     // Wifi 8 + 0 = 8
            }
        }

        var description: String {
            switch self {
            case .trusted: return "Trusted/Private Network" // WIFI: 8 + 4 = 12
            case .isPublic: return "Public/Shared Network"  // WIFI: 8 - 5 = 3
            case .unknown: return "Unknown Network Trust"   // WIFI: 8 + 0 = 8
            }
        }
    }

    enum EnvironmentType: String, CaseIterable {
        case privateControlled = "private_controlled"
        case semiPrivate = "semi_private"
        case publicSpace = "public_space"

        var displayName: String {
            switch self {
            case .privateControlled: return "Private/Controlled Location"
            case .semiPrivate: return "Semi-Private Location"
            case .publicSpace: return "Public Space"
            }
        }

        var scoreModifier: Int {
            switch self {
            case .privateControlled: return 10
            case .semiPrivate: return 5
            case .publicSpace: return 0
            }
        }

        var description: String {
            switch self {
            case .privateControlled: return "Home, private office, controlled access area"
            case .semiPrivate: return "Workplace common areas, known environment"
            case .publicSpace: return "Coffee shops, airports, public spaces"
            }
        }
        var icon: String {
            switch self {
            case .privateControlled: return "house.fill"
            case .semiPrivate: return "building.2.fill"
            case .publicSpace: return "figure.walk"
            }
        }

        var color: Color {
            switch self {
            case .privateControlled: return .green
            case .semiPrivate: return .blue
            case .publicSpace: return .orange
            }
        }
    }

    enum LocationSecurityContext: String, CaseIterable {
        case privateResidence = "private_residence"
        case workTrustedLocation = "work_trusted"
        case inTransitVehicle = "in_transit"
        case publicSpace = "public_space"
        case otherUncertain = "other_uncertain"

        var displayName: String {
            switch self {
            case .privateResidence: return "Private Residence/Home"
            case .workTrustedLocation: return "Work/Trusted Location"
            case .inTransitVehicle: return "In Transit/Vehicle"
            case .publicSpace: return "Public Space"
            case .otherUncertain: return "Other/Uncertain"
            }
        }

        var securityScore: Int {
            switch self {
            case .privateResidence: return 15
            case .workTrustedLocation: return 12
            case .inTransitVehicle: return 10
            case .publicSpace: return 5
            case .otherUncertain: return 8
            }
        }

        var riskDescription: String {
            switch self {
            case .privateResidence: return "Controlled environment, trusted network, minimal observation risk"
            case .workTrustedLocation: return "Semi-controlled environment, known network, familiar people"
            case .inTransitVehicle: return "Temporary location, cellular connection likely, moderate privacy"
            case .publicSpace: return "Shared environment, unknown network risks, observation potential"
            case .otherUncertain: return "Neutral assessment for ambiguous situations"
            }
        }

        var icon: String {
            switch self {
            case .privateResidence: return "house.fill"
            case .workTrustedLocation: return "building.2.fill"
            case .inTransitVehicle: return "car.fill"
            case .publicSpace: return "figure.walk"
            case .otherUncertain: return "questionmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .privateResidence: return .green
            case .workTrustedLocation: return .blue
            case .inTransitVehicle: return .orange
            case .publicSpace: return .red
            case .otherUncertain: return .gray
            }
        }
    }

    enum NetworkTrustSuggestion {
        case remembered(NetworkTrustLevel, String?)
        case locationBased(NetworkTrustLevel, String)
    }

    override init() {
        super.init()
        setupNetworkMonitoring()
        setUpLocationManager()
    }

    deinit {
        monitor.cancel()
        locationTimer?.invalidate()
    }

    // MARK: Setup Methods
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateNetworkStatus(path: path)
            }
        }
        monitor.start(queue: queue)
    }

    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationPermissionStatus = locationManager.authorizationStatus
    }

    private func updateNetworkStatus(path: Network.NWPath) {
        if path.usesInterfaceType(.cellular) {
            networkType = .cellular
            currentNetworkName = "Cellular"
            networkTrustLevel = nil // Cellular is inherently trusted
        } else if path.usesInterfaceType(.wifi) {
            networkType = .wifi
            // dont override user confirmation
            if networkTrustLevel == nil {
                networkTrustLevel = .unknown
            }
        } else {
            networkType = .unknown
            currentNetworkName = "Unknown Connection"
            networkTrustLevel = .unknown
        }
    }

    // MARK: Public Interface
    var hasLocationPermission: Bool {
        return locationPermissionStatus == .authorizedWhenInUse || locationPermissionStatus == .authorizedAlways
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func performLocationSnapshot() {
        guard !isLocationRequestInProgress else { return }

        locationError = nil

        guard hasLocationPermission else {
            locationError = "Location permission required"
            detectionConfidence = .failed("Location permission required")
            return
        }

        isLocationRequestInProgress = true

        // set timeout timer
        locationTimer = Timer.scheduledTimer(withTimeInterval: locationTimeout, repeats: false) { [weak self] _ in
            self?.handleLocationTimeout()
        }
        // request single location update
        locationManager.requestLocation()
    }

    // MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        cleanupLocationRequest()

        guard let location = locations.last else { return }

        lastLocationUpdate = Date()
        locationError = nil

        // create snapshot immediately with basic info
        let basicSnapshot = LocationSnapshot(
            coordinate: location.coordinate,
            accuracy: location.horizontalAccuracy,
            timestamp: Date(),
            detectedInfo: DetectedLocationInfo(
                primaryName: nil,
                streetAddress: nil,
                neighborhood: nil,
                areasOfInterest: [],
                rawPlacemark: nil
            )
        )

        DispatchQueue.main.async {
            self.currentLocationSnapshot = basicSnapshot
            self.detectionConfidence = .low("Basic location acquired, getting details...")
            self.checkForSmartSuggestion(location: location)
        }

        // perform geocoding for detailed info
        performDetailedGeocode(for: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        cleanupLocationRequest()
        DispatchQueue.main.async {
            self.locationError = error.localizedDescription
            self.detectionConfidence = .failed("Location detection failed: \(error.localizedDescription)")
            print("Location detection failed: \(error.localizedDescription)")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // the authorization status is now available directly from the manager object
        let status = manager.authorizationStatus
        DispatchQueue.main.async {
            self.locationPermissionStatus = status
        }
    }

    private func handleLocationTimeout() {
        cleanupLocationRequest()
        DispatchQueue.main.async {
            self.locationError = "Location request timed out"
            self.detectionConfidence = .failed("Location request timed out")
        }
    }

    private func cleanupLocationRequest() {
        isLocationRequestInProgress = false
        locationTimer?.invalidate()
        locationTimer = nil
    }

    // Geocoding
    private func performDetailedGeocode(for location: CLLocation) {
        let geocoder = CLGeocoder()
        // setup timeout for geocoder
        var isGeocodeComplete = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if !isGeocodeComplete {
                geocoder.cancelGeocode()
                self.detectionConfidence = .medium("Geocoding timeout - using partial location data")
            }
        }

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            isGeocodeComplete = true

            DispatchQueue.main.async {
                if let error = error {
                    self.detectionConfidence = .medium("Could not get detailed location: \(error.localizedDescription)")
                    return
                }

                guard let placemark = placemarks?.first else {
                    self.detectionConfidence = .low("No detailed location data available")
                    return
                }
                self.processGeocodingResult(placemark, for: location)
            }
        }
    }

    func getNetworkSuggestion() -> NetworkTrustSuggestion? {
        guard networkType == .wifi else { return nil }

        let currentNetworkHash = hashCurrentNetwork()

        if let remembered = networkMemory.first(where: { $0.ssidHash == currentNetworkHash }) {
            return .remembered(remembered.trustLevel, remembered.userLabel)
        }

        // check if we are in familiar location
        if let locationContext = getCurrentLocationContext() {
            switch locationContext {
            case .privateResidence:
                return .locationBased(.trusted, "Looks like you're at home")
            case .workTrustedLocation:
                return .locationBased(.trusted, "Looks like you're at work")
            case .publicSpace:
                return .locationBased(.isPublic, "Public location detected")
            default:
                break
            }
        }
        return nil
    }

    func confirmAndRememberNetworkTrust(_ trusted: Bool, userLabel: String? = nil) {
        confirmNetworkTrust(trusted)

        // remember this network for future use

        let context = NetworkContext(
            ssidHash: hashCurrentNetwork(),
            trustLevel: trusted ? .trusted : .isPublic,
            locationHash: hasCurrentLocation(),
            timeStamp: Date(),
            userLabel: userLabel
        )

        // remove any existing memory for this network
        networkMemory.removeAll { $0.ssidHash == context.ssidHash }
        networkMemory.append(context)

        // keep only recent memories (last 50 networks)
        if networkMemory.count > 50 {
            networkMemory.removeFirst()
        }
    }

    private func hashCurrentNetwork() -> String {
        // create privacy preserving has of current network
        return "\(currentNetworkName)".hash.description
    }

    private func hasCurrentLocation() -> String? {
        guard let snapshot = currentLocationSnapshot else { return nil }
        return "\(snapshot.coordinate.latitude)_\(snapshot.coordinate.longitude)".hash.description
    }

    private func getCurrentLocationContext() -> LocationSecurityContext? {
        return locationContext
    }

    private func processGeocodingResult(_ placemark: CLPlacemark, for location: CLLocation) {
        let detectedInfo = extractLocationInfo(from: placemark)

        let enhancedSnapshot = LocationSnapshot(
            coordinate: location.coordinate,
            accuracy: location.horizontalAccuracy,
            timestamp: Date(),
            detectedInfo: detectedInfo
        )

        currentLocationSnapshot = enhancedSnapshot
        detectionConfidence = assessDetectionConfidence(for: detectedInfo)
        // check for smart suggestions with enhanced data
        checkForSmartSuggestion(location: location)
    }

    private func extractLocationInfo(from placemark: CLPlacemark) -> DetectedLocationInfo {
        // Primary name
        let primaryName = placemark.name

        // street address
        var streetAddress: String?
        if let number = placemark.subThoroughfare, let street = placemark.thoroughfare {
            streetAddress = "\(number) \(street)"
        } else if let street = placemark.thoroughfare {
            streetAddress = street
        }

        // neighborhood context
        let neighborhood = placemark.subLocality ?? placemark.locality
        // areas of interest
        let areasOfInterest = placemark.areasOfInterest ?? []

        return DetectedLocationInfo(
            primaryName: primaryName,
            streetAddress: streetAddress,
            neighborhood: neighborhood,
            areasOfInterest: areasOfInterest,
            rawPlacemark: placemark
        )
    }

    // MARK: Detection Confidence Assessment
    // This function evaluates how reliable our location detection is based on the quality and specificity of the data we received

    private func assessDetectionConfidence(for info: DetectedLocationInfo) -> DetectionConfidence {
        // HIGH CONFIDENCE: We detected a specific, identifiable place
        // This could be a business, landmark, or well-known location
        if let primaryName = info.primaryName, !primaryName.isEmpty,
            // check if we have additional context that confirms this is a specific place
           (info.areasOfInterest.count > 0 || containsVenueKeywords(primaryName)) {
            return .high("Detected specific location: \(primaryName)")
        }

        // MEDIUM CONFIDENCE: We have a street address with neighborhood context
        // This gives us a good sense of the area but not a specific business/landmark
        if let streetAddress = info.streetAddress, !streetAddress.isEmpty, let neighborhood = info.neighborhood, !neighborhood.isEmpty {
            return .medium("Located at \(streetAddress), \(neighborhood)")
        }
        // MEDIUM CONFIDENCE: We have a primary name but no additional context
        // Could be a street name or general area
        if let primaryName = info.primaryName, !primaryName.isEmpty {
            return .medium("General area: \(primaryName)")
        }

        // LOW CONFIDENCE: We have basic location components but limited specificity
        // This might be just a street address OR just a neighborhood
        if info.streetAddress != nil || info.neighborhood != nil {
            let availableInfo = [info.streetAddress, info.neighborhood]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: ", ")

            return .low("Basic location data: \(availableInfo.isEmpty ? info.displayName : availableInfo)")
        }

        // FAILED: We don't have enough useful location information
        // This could happen due to network issues, rate limiting, or poor GPS signal
        return .failed("Insufficient location data - only coordinates available")
    }


    private func containsVenueKeywords(_ name: String) -> Bool {
        let keywords = ["Airport", "Hospital", "Mall", "Station", "University", "Hotel", "Restaurant", "Cafe", "Store"]
        return keywords.contains { name.localizedCaseInsensitiveContains($0) }
    }

    // WHAT THIS MEANS FOR YOUR APP:
    // - HIGH: User can trust the location detection for security context decisions
    // - MEDIUM: Location is reasonably accurate, good for general area assessment
    // - LOW: Basic location info, user should verify context manually
    // - FAILED: Location detection didn't work well, rely on user input

    // Mark: Smart suggestions (Cache)
    private func checkForSmartSuggestion(location: CLLocation) {
        if let cached = findCacheContextNearby(location: location) {
            smartSuggestion = cached.environmentType
        }
    }

    private func findCacheContextNearby(location: CLLocation) -> CachedEnvironmentContext? {
        let now = Date()

        // clean expired entries
        environmentContextCache.removeAll { now.timeIntervalSince($0.timeStamp) > cacheMaxAge }

        for cached in environmentContextCache {
            let cachedLocation = CLLocation(latitude: cached.coordinate.latitude, longitude: cached.coordinate.longitude)
            if location.distance(from: cachedLocation) <= cacheRadius {
                return cached
            }
        }
        return nil
    }

    private func cacheEnvironmentSelection(_ environment: EnvironmentType, for snapshot: LocationSnapshot) {
        let cached = CachedEnvironmentContext(
            coordinate: snapshot.coordinate,
            environmentType: environment,
            timeStamp: Date(),
            displayName: snapshot.detectedInfo.displayName
        )
        // remove any existing cache entry for this location
        environmentContextCache.removeAll { existing in
            let existingLocation = CLLocation(
                latitude: existing.coordinate.latitude,
                longitude: existing.coordinate.longitude
            )
            let currentLocation = CLLocation(
                latitude: snapshot.coordinate.latitude,
                longitude: snapshot.coordinate.longitude
            )
            return existingLocation.distance(from: currentLocation) <= cacheRadius
        }

        // Add new cache entry
        environmentContextCache.append(cached)

        // limit cache size
        if environmentContextCache.count > 50 {
            environmentContextCache.removeFirst()
        }
    }

    // MARK: User Confirmation Methods
    func confirmNetworkTrust(_ trusted: Bool) {
        userConfirmedNetworkType = trusted
        networkTrustLevel = trusted ? .trusted : .isPublic
    }

    func selectEnvironmentType(_ environment: EnvironmentType) {
        userSelectedEnvironment = environment
        environmentType = environment

        if let snapshot = currentLocationSnapshot {
            cacheEnvironmentSelection(environment, for: snapshot)
        }
        smartSuggestion = nil
    }

    // MARK: Scoring Logic
    func getEnvironmentScore() -> Int {
        let networkScore = getNetworkScore()
        let environmentModifier = getEnvironmentModifier()
        return min(networkScore + environmentModifier, maxScore)
    }

    func getNetworkScore() -> Int {
        let baseScore = networkType.baseScore

        if networkType == .cellular {
            return baseScore // Cellular is always trusted
        }

        // apply trust level modifier for Wi-Fi
        guard let trustLevel = networkTrustLevel else {
            return baseScore // unknown trust level
        }

        return max(baseScore + trustLevel.scoreModifier, 0)
    }

    func getEnvironmentModifier() -> Int {
        guard let environment = environmentType else {
            return 0 // no environment context
        }

        return environment.scoreModifier
    }

    func needsUserConfirmation() -> Bool {
        let needsNetworkConfirmation = networkType == .wifi && networkTrustLevel == nil
        let needsEnvironmentConfirmation = environmentType == nil

        return needsNetworkConfirmation || needsEnvironmentConfirmation
    }

    func getRecommendationsForCurrentScore() -> [String] {
        let score = getEnvironmentScore()
        switch score {
        case 20...25:
            return ["Excellent - Secure environment for all sensitive activities"]
        case 15...19:
            return ["Good - Safe for most sensitive activities"]
        case 10...14:
            return ["Moderate - Consider improving network or location security", "Use cellular data if available", "Move to a more private location if possible"]
        case 5...9:
            return ["Caution - Multiple environmental risk factors present", "Avoid sensitive activities", "Switch to cellular data", "Find a private location"]
        case 0...4:
            return ["High Risk - Environment not safe for sensitive activities", "Do not access banking or sensitive accounts", "Use cellular data only", "Move to a secure location immediately"]
        default:
            return ["Unable to assess current environment"]
        }

    }

}
