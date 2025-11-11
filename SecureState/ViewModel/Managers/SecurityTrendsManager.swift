//
//  SecurityTrendsManager.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftData

@MainActor
class SecurityTrendsManager: ObservableObject {
    // Published state
    @Published var currentVulnerabilityCount: Int = 0
    @Published var currentCriticalCount: Int = 0
    @Published var currentHighCount: Int = 0
    @Published var currentMediumCount: Int = 0
    @Published var historicalData: [TrendDataPoint] = []
    @Published var isLoading: Bool = false
    @Published var lastUpdateDate: Date?
    @Published var errorMessage: String?
    @Published var sourceAttribution: String = "Source: NIST National Vulnerability Database (NVD)"
    @Published var latestVulnerabilities: [SimpleCVE] = []

    @Published var criticalCVEs: [SimpleCVE] = []
    @Published var highCVEs: [SimpleCVE] = []
    @Published var mediumCVEs: [SimpleCVE] = []
    @Published var allScoredCVEs: [SimpleCVE] = []

    // Configuration
    private let maxHistoricalDays: Int = 90
    private let cooldownInterval: TimeInterval = 86400 // 24 hours
    private let modelContext: ModelContext

    private var isFetching: Bool = false

    // API Endpoints (HTTPS only)
    private let nvdEndpoint = "https://services.nvd.nist.gov/rest/json/cves/2.0"

    // Weekly aggregate stats
    @Published var weeklyTotal: Int = 0
    @Published var weeklyCritical: Int = 0
    @Published var weeklyHigh: Int = 0
    @Published var weeklyMedium: Int = 0

    // Recent sample CVEs
    @Published var recentSampleCVEs: [SimpleCVE] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadCachedData()
    }

    // MARK: Public Methods
    /// Fetch latest trend data (respects 24h cooldown)
    // Add these properties to track fetch state better
    private var lastFetchTimestamp: Date? {
        get { UserDefaults.standard.object(forKey: "lastTrendsFetchTimestamp") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastTrendsFetchTimestamp") }
    }

    private var lastFetchCalendarDay: Date? {
        get { UserDefaults.standard.object(forKey: "lastFetchCalendarDay") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastFetchCalendarDay") }
    }

    // Check if this is user's first time viewing trends
    var isFirstTimeUser: Bool {
        return historicalData.isEmpty && lastUpdateDate == nil
    }

    // Get welcome message for first-time users
    var firstTimeWelcomeMessage: String {
        """
            Welcome to Security Trends! 
            
            This feature tracks global cybersecurity activity based on when you use the app. Your first data point will be collected today, and trends will build over the next 90 days.
            
            Pull to refresh to get your first data snapshot.
        """
    }

    // Replace the existing shouldFetchToday() with this improved version
    func shouldFetchToday() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        // Check 1: Have we ever fetched?
        guard let lastFetchDay = lastFetchCalendarDay else {
            print("📅 No previous fetch - fetching")
            return true
        }

        // Check 2: Is it a new calendar day?
        let lastDay = calendar.startOfDay(for: lastFetchDay)
        if today > lastDay {
            print("📅 New calendar day detected - fetching")
            return true
        }

        // Check 3: Rate limiting - prevent multiple fetches within same day
        if let lastTimestamp = lastFetchTimestamp {
            let timeSinceLastFetch = now.timeIntervalSince(lastTimestamp)
            if timeSinceLastFetch < 3600 { // Minimum 1 hour between fetches
                print("⏱️ Rate limit: Only \(Int(timeSinceLastFetch/60)) minutes since last fetch")
                return false
            }
        }

        print("✅ Same day, but enough time has passed - allowing fetch")
        return true
    }

    // Add this method to clear stale CVE samples
    private func clearStaleCVESamples() {
        print("🗑️ Clearing stale CVE samples")

        // Clear all sample CVEs since they're daily snapshots
        latestVulnerabilities.removeAll()
        criticalCVEs.removeAll()
        highCVEs.removeAll()
        mediumCVEs.removeAll()
        allScoredCVEs.removeAll()
    }

    // Update fetchLatestData to use new strategy
    func fetchLatestData(skipRateLimit: Bool = false) async {

        guard !isFetching else {
            return
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Check if we should fetch
        if !skipRateLimit {
            guard shouldFetchToday() else {
                print("⏭️ Skipping fetch - not needed")
                return
            }
        } else {
            print("⚡ Skipping rate limit check (forced refresh)")
        }

        await MainActor.run {
            isFetching = true
            isLoading = true
            errorMessage = nil
        }

        defer {
            Task { @MainActor in
                isFetching = false
            }
        }

        do {
            // Clear old CVE samples before fetching new ones
            await MainActor.run {
                clearStaleCVESamples()
            }

            let vulnerabilityData = try await fetchNVDData()

            // Check if we already have data for today (using in-memory check instead of predicate)
            let existingTodayData = historicalData.first { dataPoint in
                calendar.isDate(dataPoint.date, inSameDayAs: today)
            }

            if let existingData = existingTodayData {
                print("📊 Already have data for today - updating in place")
                // Update the existing data point instead of creating a new one
                if let index = historicalData.firstIndex(where: { $0.id == existingData.id }) {
                    let updatedPoint = TrendDataPoint(
                        date: today,
                        total: vulnerabilityData.total,
                        critical: vulnerabilityData.critical,
                        high: vulnerabilityData.high,
                        medium: vulnerabilityData.medium
                    )
                    historicalData[index] = updatedPoint

                    // Update SwiftData - fetch by date range instead of using isDate in predicate
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: today)!
                    let descriptor = FetchDescriptor<StoredTrendData>(
                        predicate: #Predicate<StoredTrendData> { stored in
                            stored.date >= today && stored.date < endOfDay
                        }
                    )
                    if let existingStored = try? modelContext.fetch(descriptor).first {
                        existingStored.vulnerabilityCount = vulnerabilityData.total
                        existingStored.criticalCount = vulnerabilityData.critical
                        existingStored.highCount = vulnerabilityData.high
                        existingStored.mediumCount = vulnerabilityData.medium
                        try? modelContext.save()
                    }
                }
            } else {
                print("📊 Creating new data point for today")
                // Create new data point for today
                let dataPoint = TrendDataPoint(
                    date: today,
                    total: vulnerabilityData.total,
                    critical: vulnerabilityData.critical,
                    high: vulnerabilityData.high,
                    medium: vulnerabilityData.medium
                )

                await MainActor.run {
                    self.historicalData.append(dataPoint)
                }

                persistDataPoint(dataPoint)
            }

            // Update current counts and CVE samples (these are always replaced)
            await MainActor.run {
                self.currentVulnerabilityCount = vulnerabilityData.total
                self.currentCriticalCount = vulnerabilityData.critical
                self.currentHighCount = vulnerabilityData.high
                self.currentMediumCount = vulnerabilityData.medium
                self.lastUpdateDate = Date()
                self.isLoading = false
            }

            // Update timestamps
            lastFetchTimestamp = Date()
            lastFetchCalendarDay = today

            // Clean old data (keep 90 days)
            cleanOldData()

        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch trend data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    // The cleanOldData function was already correct, no changes needed

    // Update cleanOldData to be more aggressive with old CVE samples
    private func cleanOldData() {
        guard let cutOffDate = Calendar.current.date(byAdding: .day, value: -maxHistoricalDays, to: Date()) else {
            return
        }

        let descriptor = FetchDescriptor<StoredTrendData>(
            predicate: #Predicate { $0.date < cutOffDate }
        )

        do {
            let oldData = try modelContext.fetch(descriptor)
            oldData.forEach { modelContext.delete($0) }
            try modelContext.save()

            // Update in-memory data
            historicalData = historicalData.filter { $0.date >= cutOffDate }
        } catch {
            print("❌ Failed to clean old data: \(error)")
        }
    }

    /// Manual refresh (user-triggered, respects cooldown)
    func manualRefresh(force: Bool = false) async {
        guard !isLoading else { return }

        if force {
            await fetchLatestData(skipRateLimit: true)
        } else if shouldFetchToday() {
            await fetchLatestData()
        } else {
            print("Already up to date")
        }
    }

    /// Get trend insight text
    func getTrendInsight() -> String {
        guard historicalData.count >= 2 else {
            return "Collecting trend data..."
        }

        let recent = historicalData.suffix(7)
        let avgRecent = recent.reduce(0) { $0 + $1.vulnerabilityCount } / recent.count

        let older = historicalData.dropLast(7).suffix(7)
        let avgOlder = older.isEmpty ? avgRecent : older.reduce(0) { $0 + $1.vulnerabilityCount } / older.count

        let change = Double(avgRecent - avgOlder) / Double(avgOlder) * 100

        // Calculate critical percentage
        let recentCritical = recent.reduce(0) { $0 + $1.criticalCount }
        let criticalPercentage = avgRecent > 0 ? Double(recentCritical) / Double(avgRecent * recent.count) * 100 : 0

        if criticalPercentage > 20 {
            return "High number of critical vulnerabilities detected (\(Int(criticalPercentage))%). Keep systems updated immediately."
        } else if change > 10 {
            return "Vulnerabilities increased \(Int(abs(change)))% this week. Stay vigilant and apply security patches."
        } else if change < -10 {
            return "Vulnerability reports decreased \(Int(abs(change)))% this week. Continue monitoring for new threats."
        } else {
            return "Vulnerability activity remains stable. Keep your systems updated and maintain good security practices."
        }
    }

    // MARK: - Private API Methods

    private func fetchNVDData() async throws -> WeeklyVulnerabilityData {
        // Get API key from secure storage (optional for NVD - works without key but with lower rate limits)
        let apiKey = APIKeyManager.retrieveNVDKey()

        // Calculate date range (last 7 days)
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate) else {
            throw TrendsError.invalidDate
        }

        let dateFormatter = ISO8601DateFormatter()
        let startDateStr = dateFormatter.string(from: startDate)
        let endDateStr = dateFormatter.string(from: endDate)

        print("📅 Fetching CVEs from \(startDateStr) to \(endDateStr)")


        guard let baseURL = URL(string: nvdEndpoint) else {
            throw TrendsError.invalidURL(nvdEndpoint)
        }

        // Builds the API request URL with parameters
        // The API needs to know WHAT you want (date range) And HOW MUCH you want (20 results, not all 997)
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "pubStartDate", value: startDateStr),
            URLQueryItem(name: "pubEndDate", value: endDateStr),
            URLQueryItem(name: "resultsPerPage", value: "20")
        ]

        guard let finalURL = components?.url else {
            throw TrendsError.invalidURL("URL")
        }

        // Creates a GET request (asking for data, not sending data)
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"

        // API key is optional but recommended
        if let apiKey = apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "apiKey")
        }

        // Actually sends the request to NVD servers, Waits for their response, await = "Pause here until the server responds"
        let (data, response) = try await URLSession.shared.data(for: request)

        // Checks if the request succeeded HTTP status codes: 200 = success, 404 = not found, 500 = server error
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TrendsError.invalidResponse
        }

        // Converts raw JSON text into Swift objects
        guard let cveResponse = try? JSONDecoder().decode(NVDCVEResponse.self, from: data) else {
            throw TrendsError.invalidResponse
        }

        let weeklyTotal = cveResponse.totalResults // eg. 997

        // Gets the actual array of 20 CVE objects Handles the case where the API returns nothing
        guard let vulnerabilities = cveResponse.vulnerabilities else {
            return WeeklyVulnerabilityData(
                total: 0,
                critical: 0,
                high: 0,
                medium: 0
            )
        }

        // Count severity from the sample we received
        var sampleCritical = 0
        var sampleHigh = 0
        var sampleMedium = 0
        var sampleLow = 0

        // Loops through your 20 CVEs Counts how many are Critical, High, Medium
        for vuln in vulnerabilities {
            let severityString = vuln.cve.metrics?.cvssMetricV31?.first?.cvssData.baseSeverity ??
            vuln.cve.metrics?.cvssMetricV2?.first?.cvssData.baseSeverity ??
            "UNKNOWN"

            let severity = SimpleCVE.Severity(rawValue: severityString.uppercased()) ?? .unknown

            switch severity {
            case .critical: sampleCritical += 1
            case .high: sampleHigh += 1
            case .medium: sampleMedium += 1
            case .low: sampleLow += 1
            case .unknown: break
            }
        }

        //Uses statistics to estimate the full breakdown, You can't download all 986, so you estimate from your sample
        let sampleSize = Double(vulnerabilities.count)
        let weeklyCritical = sampleSize > 0 ? Int(Double(sampleCritical) * (Double(weeklyTotal) / sampleSize)) : 0
        let weeklyHigh = sampleSize > 0 ? Int(Double(sampleHigh) * (Double(weeklyTotal) / sampleSize)) : 0
        let weeklyMedium = sampleSize > 0 ? Int(Double(sampleMedium) * (Double(weeklyTotal) / sampleSize)) : 0

        var recentCVEs: [SimpleCVE] = []

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // fallback formatter without fractional seconds
        let fallbackFormatter = ISO8601DateFormatter()
        fallbackFormatter.formatOptions = [.withInternetDateTime]

        // Even simpler fallback
        let simpleDateFormatter = DateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        simpleDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        // Takes the first 15 CVEs from your 20 Extracts all the details (description, date, products, etc.)
        for vuln in vulnerabilities.prefix(15) {
            let id = vuln.cve.id

            // get severity
            let severityString = vuln.cve.metrics?.cvssMetricV31?.first?.cvssData.baseSeverity ??
            vuln.cve.metrics?.cvssMetricV2?.first?.cvssData.baseSeverity ??
            "UNKNOWN"

            let severity = SimpleCVE.Severity(rawValue: severityString.uppercased()) ?? .unknown

            // Get English Description
            let description: String
            if let descriptions = vuln.cve.descriptions,
               let englishDesc = descriptions.first(where: { $0.lang == "en"})?.value {
                description = englishDesc
            } else {
                description = "Description not yet available for this vulnerability."
            }

            // Get weakness type (CWE) - User Friendly
            let weaknessType: String?
            if let weakness = vuln.cve.weakness,
               let firstWeakness = weakness.first,
               let cweDesc = firstWeakness.description.first(where: { $0.lang == "en"})?.value {
                // Parse CWE-XXX to get readable name
                weaknessType = parseCWEToReadableName(cweDesc)
            } else {
                weaknessType = nil
            }

            // Get affected products (simplified)
            var affectedProducts: [String] = []
            var seenProducts = Set<String>()

            if let configs = vuln.cve.configurations {
                for config in configs {
                    if let nodes = config.nodes {
                        for node in nodes {
                            if let cpeMatches = node.cpeMatch {
                                for cpe in cpeMatches.prefix(3) { // Only take first 3
                                    if let productName = extractProductFromCPE(cpe.criteria) {
                                        // Only add it if we havent seen it before
                                        if !seenProducts.contains(productName) {
                                            affectedProducts.append(productName)
                                            seenProducts.insert(productName)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Try multiple date parsing strategies
            let dateString = vuln.cve.published
            var date: Date?

            // Strategy 1: Full ISO8601 with fractional seconds
            date = isoFormatter.date(from: dateString)

            // Strategy 2: ISO8601 without fractional seconds
            if date == nil {
                date = fallbackFormatter.date(from: dateString)
            }

            // Strategy 3: Custom format
            if date == nil {
                date = simpleDateFormatter.date(from: dateString)
            }

            // Strategy 4: Try removing timezone and parsing just the date
            if date == nil {
                let cleanedString = dateString.components(separatedBy: ".").first ?? dateString
                let cleanedString2 = cleanedString.components(separatedBy: "Z").first ?? cleanedString
                date = fallbackFormatter.date(from: cleanedString2 + "Z")
            }

            guard let publishedDate = date else {
                continue
            }
            recentCVEs.append(
                SimpleCVE(
                    id: id,
                    severity: severity,
                    published: publishedDate,
                    description: description,
                    weaknessType: weaknessType,
                    affectedProducts: Array(affectedProducts.prefix(5)) // MAX 5 products
                )
            )
        }

        // Categorize the detailed CVEs by severity
        let critical = recentCVEs.filter { $0.severity == .critical }
        let high = recentCVEs.filter { $0.severity == .high }
        let medium = recentCVEs.filter { $0.severity == .medium }
        let allScored = recentCVEs.filter { $0.severity != .unknown }

        //Updates your @Published properties
        await MainActor.run {
            // Store weekly aggregates (for cards/charts)
            self.currentVulnerabilityCount = weeklyTotal
            self.currentCriticalCount = weeklyCritical
            self.currentHighCount = weeklyHigh
            self.currentMediumCount = weeklyMedium

            // Store detailed CVE samples (for list)
            self.latestVulnerabilities = recentCVEs
            self.criticalCVEs = Array(critical.prefix(15))
            self.highCVEs = Array(high.prefix(15))
            self.mediumCVEs = Array(medium.prefix(15))
            self.allScoredCVEs = Array(allScored.prefix(20))

        }

        // This gets saved to SwiftData so
        return WeeklyVulnerabilityData(
            total: weeklyTotal,
            critical: weeklyCritical,
            high: weeklyHigh,
            medium: weeklyMedium
        )
    }

    // Convert CWE-XXX to readable name
    private func parseCWEToReadableName(_ cwe: String) -> String {
        // CWE string format: "CWE-79" or "CWE-79: Cross-site Scripting"
        if cwe.contains(":") {
            // Has description, extract it
            let parts = cwe.components(separatedBy: ":")
            if parts.count > 1 {
                return parts[1].trimmingCharacters(in: .whitespaces)
            }
        }
        return cwe
    }

    // Extract product name from CPE string
    private func extractProductFromCPE(_ cpe: String) -> String? {
        // CPE format: cpe:2.3.a:vendor:product:version...
        let parts = cpe.components(separatedBy: ":")
        if parts.count >= 5 {
            let vendor = parts[3]
            let product = parts[4]

            // make it readable
            let readableVendor = vendor.replacingOccurrences(of: "_", with: " ").capitalized
            let readableProduct = product.replacingOccurrences(of: "_", with: " ").capitalized

            return "\(readableVendor) \(readableProduct)"
        }
        return nil
    }

    // Persistence
    private func loadCachedData() {
        let descriptor = FetchDescriptor<StoredTrendData>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        do {
            let stored = try modelContext.fetch(descriptor)
            self.historicalData = stored.map {
                TrendDataPoint(
                    date: $0.date,
                    total: $0.vulnerabilityCount,
                    critical: $0.criticalCount,
                    high: $0.highCount,
                    medium: $0.mediumCount
                )
            }

            if let latest = stored.last {
                self.currentVulnerabilityCount = latest.vulnerabilityCount
                self.currentCriticalCount = latest.criticalCount
                self.currentHighCount = latest.highCount
                self.currentMediumCount = latest.mediumCount
            }

            // Load the actual last fetch time (not the data date)
            if let lastFetch = UserDefaults.standard.object(forKey: "lastTrendsFetchDate") as? Date {
                self.lastUpdateDate = lastFetch
            }
        } catch {
            print("Failed to load cached trend data: \(error)")
        }
    }

    private func persistDataPoint(_ dataPoint: TrendDataPoint) {
        let stored = StoredTrendData(
            date: dataPoint.date,
            total: dataPoint.vulnerabilityCount,
            critical: dataPoint.criticalCount,
            high: dataPoint.highCount,
            medium: dataPoint.mediumCount
        )
        modelContext.insert(stored)

        do {
            try modelContext.save()
        } catch {
            print("Failed to persist trend data: \(error)")
        }
    }

    // MARK: - Secure API Key Retrieval
    private func getNVDAPIKey() -> String? {
        // TODO: Implement secure storage retrieval
        // For now, return placeholder - MUST be replaced with secure storage
        return APIKeyManager.retrieveNVDKey()
    }

    // Fetch detailed CVE infomation for display
    func fetchLatestCVEDetails() async -> [SimpleCVE] {
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate) else {
            return []
        }
        let dateFormatter = ISO8601DateFormatter()
        let startDateStr = dateFormatter.string(from: startDate)
        let endDateStr = dateFormatter.string(from: endDate)

        guard let baseURL = URL(string: nvdEndpoint) else { return [] }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "pubStartDate", value: startDateStr),
            URLQueryItem(name: "pubEndDate", value: endDateStr),
            URLQueryItem(name: "resultsPerPage", value: "15")
        ]
        guard let finalURL = components?.url else { return [] }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"

        if let apiKey = APIKeyManager.retrieveNVDKey() {
            request.setValue(apiKey, forHTTPHeaderField: "apiKey")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return []
            }

            guard let cveResponse = try? JSONDecoder().decode(NVDCVEResponse.self, from: data) else {
                return []
            }

            var detailedCVEs: [SimpleCVE] = []
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let fallbackFormatter = ISO8601DateFormatter()
            fallbackFormatter.formatOptions = [.withInternetDateTime]

            if let vulnerabilities = cveResponse.vulnerabilities {
                for vuln in vulnerabilities.prefix(15) {
                    let id = vuln.cve.id
                    let severityString = vuln.cve.metrics?.cvssMetricV31?.first?.cvssData.baseSeverity ??
                    vuln.cve.metrics?.cvssMetricV2?.first?.cvssData.baseSeverity ?? "UNKNOWN"

                    let severity = SimpleCVE.Severity(rawValue: severityString.uppercased()) ?? .unknown

                    // Parse date
                    var publishedDate: Date?
                    let dateString = vuln.cve.published
                    publishedDate = isoFormatter.date(from: dateString) ?? fallbackFormatter.date(from: dateString)

                    guard let date = publishedDate else {
                        continue
                    }

                    // Extract description
                    let description: String
                    if let descriptions = vuln.cve.descriptions,
                       let englishDesc = descriptions.first(where: { $0.lang == "en"})?.value {
                        description = englishDesc
                    } else {
                        description = "Description not yet available for this vulnerability."
                    }

                    let weaknessType: String?
                    if let weakness = vuln.cve.weakness,
                       let firstWeakness = weakness.first,
                       let cweDesc = firstWeakness.description.first(where: { $0.lang == "en"})?.value {
                        weaknessType = parseCWEToReadableName(cweDesc)
                    } else {
                        weaknessType = nil
                    }

                    // Get affected products
                    var affectedProducts: [String] = []
                    var seenProducts = Set<String>()

                    if let configs = vuln.cve.configurations {
                        for config in configs {
                            if let nodes = config.nodes {
                                for node in nodes {
                                    if let cpeMatches = node.cpeMatch {
                                        for cpe in cpeMatches.prefix(3) {
                                            if let productName = extractProductFromCPE(cpe.criteria) {
                                                if !seenProducts.contains(productName) {
                                                    affectedProducts.append(productName)
                                                    seenProducts.insert(productName)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }



                    detailedCVEs.append(
                        SimpleCVE(
                            id: id,
                            severity: severity,
                            published: date,
                            description: description,
                            weaknessType: weaknessType,
                            affectedProducts: Array(affectedProducts.prefix(5))
                        )
                    )
                }
            }
            return detailedCVEs
        } catch {
            return []
        }
    }

    func getDetailedTrendContext() -> String {
        guard historicalData.count >= 7 else {
            return "Collecting baseline data... Check back after a week for trend analysis."
        }

        let recentWeek = historicalData.suffix(7)
        let avgRecent = recentWeek.reduce(0) { $0 + $1.vulnerabilityCount } / recentWeek.count
        let criticalRecent = recentWeek.reduce(0) { $0 + $1.criticalCount }
        let highRecent = recentWeek.reduce(0) { $0 + $1.highCount }

        let criticalPercentage = avgRecent > 0 ? Double(criticalRecent) / Double(avgRecent * recentWeek.count) * 100 : 0
        var context = "In the past week, there were \(avgRecent) average daily vulnerabilities. "

        if criticalPercentage > 20 {
            context += "\(Int(criticalPercentage))% were critical severity - keep your systems updated immediately. "
        } else if criticalPercentage > 10 {
            context += "\(Int(criticalPercentage))% were critical severity - stay vigilant with updates. "
        }

        if highRecent > 0 {
            context += "Additionally, \(highRecent) high-severity issues were reported. "
        }

        context += "Continue monitoring and maintaining good security practices."

        return context
    }
}
