//
//  EnhancedLocationContextDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/17/25.
//

import Foundation
import SwiftUI
import CoreLocation

class EnhancedLocationContextDetector: NSObject, ObservableObject, CLLocationManagerDelegate {

    // Published properties
    @Published var currentLocationSnapshot: LocationSnapshot?
    @Published var detectionConfidence: DetectionConfidence = .failed("")
    @Published var userSelectedContext: LocationSecurityContext?
    @Published var smartSuggestion: LocationSecurityContext?
    @Published var lastLocationUpdate: Date = Date()
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationRequestInProgress: Bool = false
    @Published var locationError: String? = nil

    // MARK: Private Properties
    private let locationManager = CLLocationManager()
    private let maxScore: Int = 15
    private var locationTimer: Timer?
    private let locationTimeout: TimeInterval = 8.0
    private let geocodingTimeout: TimeInterval = 5.0

    // Rate limiting
    private var lastGeocodingRequest: Date = Date.distantPast
    private var geocodingRateLimit: TimeInterval = 2.0
    private var geocodingRequestCount: Int = 0
    private var lastRateLimitReset: Date = Date()
    private let maxGeocodingRequestsPerMinute: Int = 20

    // Cache for smart suggestions
    private var locationContextCache: [CachedLocationContext] = []
    private let cacheRadius: CLLocationDistance = 100.0 // 100 meters
    private let cacheMaxAge: TimeInterval = 86400.0 // 24 hours

    // MARK: DateModel
    struct LocationSnapshot {
        let coordinate: CLLocationCoordinate2D
        let accuracy: CLLocationAccuracy
        let timestamp: Date
        let detectedInfo: DetectedLocationInfo

        var isAccurate: Bool {
            accuracy <= 100.0
        }
    }

    struct DetectedLocationInfo {
        let primaryName: String?            // Main identifier (business name, landmark)
        let streetAddress: String?          // Street number + street name
        let neighborhood: String?          // Sublocality or area
        let areasOfInterest: [String]      // Nearby POIs
        let rawPlacemark: CLPlacemark?     // Full placemark for debugging


        var displayName: String {
            if let primaryName = primaryName, !primaryName.isEmpty {
                return primaryName
            }

            if let streetAddress = streetAddress, !streetAddress.isEmpty {
                return streetAddress
            }
            if let neighborhood = neighborhood, !neighborhood.isEmpty {
                return neighborhood
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
            return components.joined(separator: " . ")
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

    enum DetectionConfidence {
        case high(String)    // Specific business/landmark detected
        case medium(String)  // Street address with context
        case low(String)     // Basic location components only
        case failed(String)  // No usable location data

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

    private struct CachedLocationContext {
        let coordinate: CLLocationCoordinate2D
        let context: LocationSecurityContext
        let timestamp: Date
        let displayName: String
    }


    override init() {
        super.init()
        setUpLocationManager()
        loadCacheContexts()
    }

    deinit {
        saveCacheContexts()
    }

    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationPermissionStatus = locationManager.authorizationStatus
    }

    // MARK: Public interface
    var hasLocationPermission: Bool {
        return locationPermissionStatus == .authorizedWhenInUse || locationPermissionStatus == .authorizedAlways
    }

    var isInPublicSpace: Bool {
        guard let context = userSelectedContext else { return true } // assume public if unknown
        return context == .publicSpace
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func permissionLocationSnapshot() {
        guard !isLocationRequestInProgress else {
            print("Location Request already in progress")
            return
        }
        locationError = nil

        switch locationPermissionStatus {
        case .notDetermined:
            DispatchQueue.main.async {
                self.locationError = "Location permission not requested"
                self.detectionConfidence = .failed("Location permission required")
            }
            return
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.locationError = "Location access denied"
                self.detectionConfidence = .failed("Location access denied")
            }
            return
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            return
        }

        isLocationRequestInProgress = true

        // set timeout timere
        locationTimer = Timer.scheduledTimer(withTimeInterval: locationTimeout, repeats: false) { [weak self] _ in
            self?.handleLocationTimeout()
        }
        // Request single location update
        locationManager.requestLocation()
    }

    func selectContext(_ context: LocationSecurityContext) {
        userSelectedContext = context

        // cache this selection if we have a current location
        if let snapshot = currentLocationSnapshot {
            cacheContextSelection(context, for: snapshot)
        }

        // clear smart suggestion once user makes a choice
        smartSuggestion = nil
    }

    func getSecurityScore() -> Int {
        guard let context = userSelectedContext else {
            return 0 // no context selected
        }

        let baseScore = context.securityScore
        // Apply penalty is location services are denied
        if !hasLocationPermission {
            return max(baseScore - 2, 0)
        }
        return baseScore
    }

    func needsUserContextSelection() -> Bool {
        return userSelectedContext == nil
    }

    // MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        cleanupLocationRequest()

        guard let location = locations.last else { return }

        if location.horizontalAccuracy > 200 {
            print("Location accuracy warning: \(location.horizontalAccuracy)m")
        }

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
            self.detectionConfidence = .failed("Location detection failed \(error.localizedDescription)")
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

    private func performDetailedGeocode(for location: CLLocation) {
        guard canMakeGeocodingRequest() else {
            DispatchQueue.main.async {
                self.detectionConfidence = .low("Rate limited - using basic location")
            }
            return
        }
        recordGeocodingRequest()

        let geoCoder = CLGeocoder()

        // setup timeout for geocoding
        var isGeocodeComplete = false

        DispatchQueue.main.asyncAfter(deadline: .now() + geocodingTimeout) {
            if !isGeocodeComplete {
                geoCoder.cancelGeocode()
                self.detectionConfidence = .medium("Geocoding timeout - using partial location data")
            }
        }

        geoCoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }

            isGeocodeComplete = true

            DispatchQueue.main.async {
                if let error = error {
                    self.handleGeocoingError(error)
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

    private func handleGeocoingError(_ error: Error) {
        if (error as NSError).code == -3 {
            detectionConfidence = .low("Geocoding rate limited")
        } else {
            detectionConfidence = .medium("Could not get detailed location: \(error.localizedDescription)")
        }
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
            streetAddress = "\(number) \(street))"
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
    // This function evaluates how reliable out location detection is based on the quality and specificity of the data we received

    private func assessDetectionConfidence(for info: DetectedLocationInfo) -> DetectionConfidence {
        // HIGH CONFIDENCE: We detected a specific, identifiable place
        // This could be a business, landmark, or well-known location
        if let primaryName = info.primaryName,
           !primaryName.isEmpty,
           // Check if we have additional context that confirms this is a specific place
           (info.areasOfInterest.count > 0 ||
            // Or if the name contains keywords that indicate a specific venue type
            primaryName.localizedCaseInsensitiveContains("Airport") ||
            primaryName.localizedCaseInsensitiveContains("Hospital") ||
            primaryName.localizedCaseInsensitiveContains("Mall") ||
            primaryName.localizedCaseInsensitiveContains("Station") ||
            primaryName.localizedCaseInsensitiveContains("University") ||
            primaryName.localizedCaseInsensitiveContains("Hotel") ||
            primaryName.localizedCaseInsensitiveContains("Restaurant") ||
            primaryName.localizedCaseInsensitiveContains("Cafe") ||
            primaryName.localizedCaseInsensitiveContains("Store")) {
            return .high("Detected specific location: \(primaryName)")
        }
        // MEDIUM CONFIDENCE: We have a street address with neighborhood context
        // This gives us a good sense of the area but not a specific business/landmark
        if let streetAddress = info.streetAddress,
           !streetAddress.isEmpty,
           let neighborhood = info.neighborhood,
           !neighborhood.isEmpty {
            return .medium("Located at \(streetAddress), \(neighborhood)")
        }

        // MEDIUM CONFIDENCE: We have a primary name but no additional context
        // Could be a street name or general area
        if let primaryName = info.primaryName,
           !primaryName.isEmpty {
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

    // WHAT THIS MEANS FOR YOUR APP:
    // - HIGH: User can trust the location detection for security context decisions
    // - MEDIUM: Location is reasonably accurate, good for general area assessment
    // - LOW: Basic location info, user should verify context manually
    // - FAILED: Location detection didn't work well, rely on user input

    // Mark: Smart suggestions (Cache)
    private func checkForSmartSuggestion(location: CLLocation) {
        let suggestion = findCacheContextNearby(location: location)
        smartSuggestion = suggestion?.context
    }

    private func findCacheContextNearby(location: CLLocation) -> CachedLocationContext? {
        let now = Date()

        // clean expired entries
        locationContextCache.removeAll { cachedItem in
            now.timeIntervalSince(cachedItem.timestamp) > cacheMaxAge
        }

        // find nearby cache context
        for cachedItem in locationContextCache {
            let cachedLocation = CLLocation(
                latitude: cachedItem.coordinate.latitude,
                longitude: cachedItem.coordinate.longitude
            )
            let distance = location.distance(from: cachedLocation)

            if distance <= cacheRadius {
                print("Found smart suggestion: \(cachedItem.context.displayName) (distance: \(Int(distance))m")
                return cachedItem
            }
        }
        return nil
    }

    private func cacheContextSelection(_ context: LocationSecurityContext, for snapshot: LocationSnapshot) {
        let cachedItem = CachedLocationContext(
            coordinate: snapshot.coordinate,
            context: context,
            timestamp: Date(),
            displayName: snapshot.detectedInfo.displayName
        )
        // remove any existing cache entry for this location
        locationContextCache.removeAll { cachedItem in
            let cachedLocation = CLLocation(
                latitude: cachedItem.coordinate.latitude,
                longitude: cachedItem.coordinate.longitude
            )
            let currentLocation = CLLocation(
                latitude: snapshot.coordinate.latitude,
                longitude: snapshot.coordinate.longitude
            )
            return cachedLocation.distance(from: currentLocation) <= cacheRadius
        }

        // Add new cache entry
        locationContextCache.append(cachedItem)

        // limit cache size
        if locationContextCache.count > 50 {
            locationContextCache.removeFirst()
        }
        saveCacheContexts()
    }

    // MARK: Rate Limiting for Geocoding Requests
    // Apple's CLGeocoder has usage limits to prevent abuse and preserve server resources
    // If you exceed these limits, your requests will be rejected or delayed

    private func canMakeGeocodingRequest() -> Bool {
        let now = Date()

        // Reset counter every minute
        // this implements a "sliding window" approach where we track requests per minute
        if now.timeIntervalSince(lastRateLimitReset) > 60.0 {
            geocodingRequestCount = 0
            lastRateLimitReset = now
            print("Rate limit counter reset - new minute window started")
        }

        // Check both conditions:
        // 1. Haven't exceeded our self-imposed limit of requests per minute
        // 2. Haven't made a request too recently (minimum time between requests)
        let timeSinceLastRequest = now.timeIntervalSince(lastGeocodingRequest)
        let underRateLimit = geocodingRequestCount < maxGeocodingRequestsPerMinute
        let enoughTimePassed = timeSinceLastRequest >= geocodingRateLimit

        if !underRateLimit {
            print("Rate limiting: Exceeded max requests per minute (\(maxGeocodingRequestsPerMinute))")
        }

        if !enoughTimePassed {
            print("Rate limiting: Too soon since last request (\(timeSinceLastRequest)s < \(geocodingRateLimit)s)")
        }

        return underRateLimit && enoughTimePassed
    }

    // WHY THIS IS NECESSARY:
    // 1. Apple's geocoding service has undocumented but real limits
    // 2. Exceeding limits can cause temporary bans or degraded service
    // 3. Your app might make multiple location requests quickly (user refreshing, app state changes)
    // 4. This prevents your app from being blocked by Apple's servers
    // 5. Provides graceful degradation - basic location still works even if geocoding fails

    // WHAT HAPPENS WHEN RATE LIMITED:
    // - Location coordinates still work (GPS doesn't need geocoding)
    // - You just don't get the nice business names and addresses
    // - User sees "Rate limited - using basic location" message
    // - Security assessment can still function with coordinate-based context

    private func recordGeocodingRequest() {
        lastGeocodingRequest = Date()
        geocodingRequestCount += 1
    }

    private func loadCacheContexts() {
        locationContextCache = []
    }

    private func saveCacheContexts() {

    }

    var statusDescription: String {
        switch locationPermissionStatus {
        case .denied, .restricted:
            return "Location access denied - manual assessment recommended"
        case .notDetermined:
            return "Location permission not requested"
        default:
            if let context = userSelectedContext {
                let penalty = hasLocationPermission ? "" : " (reduced: no location verification)"
                return "\(context.displayName)\(penalty)"
            } else if let snapshot = currentLocationSnapshot {
                return "Detected: \(snapshot.detectedInfo.displayName) - Please select context"
            } else {
                return "No location context selected"
            }
        }
    }

    var scoreExplanation: String {
        guard let context = userSelectedContext else {
            return "No security context selected (0/15)"
        }

        let baseScore = context.securityScore
        let finalScore = getSecurityScore()

        if !hasLocationPermission {
            return "Base: \(baseScore), Location penalty: -2, Final: \(finalScore)/15"
        } else {
            return "\(context.displayName): \(finalScore)/15"
        }
    }
}
