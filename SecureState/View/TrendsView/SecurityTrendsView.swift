//
//  SecurityTrendsView.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI
import StoreKit
import SwiftData

struct SecurityTrendsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var trendsManager: SecurityTrendsManager
    @EnvironmentObject var proManager: ProStatusManager
    @EnvironmentObject var achievementsManager: AchievementsManager
    @Environment(\.modelContext) private var modelContext

    @State private var showInfoSheet = false

    @State private var selectedCVEFilter: TrendMetric = .vulnerabilities

    enum TrendMetric: String, CaseIterable {
        case vulnerabilities = "Total"
        case critical = "Critical"
        case high = "High"
        case medium = "Medium"
    }

    init(modelContext: ModelContext) {
        _trendsManager = StateObject(wrappedValue: SecurityTrendsManager(modelContext: modelContext))
    }

    var body: some View {
        VStack(spacing: 24) {
            // Pro Status Check
            if !proManager.isPro {
                proUpgradePrompt
            } else {
                // Header with timeStamp
                headerSection

                // Main metric cards
                metricsCardsSection

                // Chart section
                chartSection

                // Insight Card
                insightSection

                if !trendsManager.allScoredCVEs.isEmpty ||
                    !trendsManager.criticalCVEs.isEmpty ||
                    !trendsManager.highCVEs.isEmpty ||
                    !trendsManager.mediumCVEs.isEmpty {
                    recentVulnerabilitiesSection
                }

                // educational context
                educationalSection

                // Attribution
                attributionSection
            }
        }
        .onAppear {
            // Dont need to add.
            if let key = APIKeyManager.retrieveNVDKey() {
                print("✅ Retrieved API key: \(key.prefix(8))...") // print only first few characters
            }
        }
        .task {
            if proManager.isPro {
                // Force initial fetch if we have no data
                if trendsManager.historicalData.isEmpty || trendsManager.latestVulnerabilities.isEmpty {
                    await trendsManager.fetchLatestData()
                } else if trendsManager.shouldFetchToday() {
                    await trendsManager.fetchLatestData()
                } else {
                    print("✅ Using cached data from today")
                }

                achievementsManager.trackTrendsView()
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            TrendsInfoSheet()
        }
    }

    struct CVEFilterChip: View {
        @EnvironmentObject var themeManager: ThemeManager
        let metric: SecurityTrendsView.TrendMetric
        let count: Int
        let isSelected: Bool
        let action: () -> Void

        var icon: String {
            switch metric {
            case .vulnerabilities: return "list.bullet"
            case .critical: return "exclamationmark.octagon.fill"
            case .high: return "exclamationmark.triangle.fill"
            case .medium: return "exclamationmark.circle.fill"
            }
        }

        var color: Color {
            switch metric {
            case .vulnerabilities: return themeManager.currentTheme.accent
            case .critical: return themeManager.currentTheme.dangerColor
            case .high: return themeManager.currentTheme.warningColor
            case .medium: return .yellow.adjustedForText(colorScheme: .dark)
            }
        }

        var body: some View {
            Button(action: {
                action()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.caption)

                    Text(metric.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if count > 0 {
                        Text("\(count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(isSelected ? color : .white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(isSelected ? .white : color.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? color : color.opacity(0.1))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var recentVulnerabilitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4){
                Text("Recent Vulnerabilities")
                    .font(.headline)
                    .fontWeight(.semibold)

                if let lastUpdate = trendsManager.lastUpdateDate {
                    Text("Showing \(trendsManager.latestVulnerabilities.count) recent examples from \(trendsManager.currentVulnerabilityCount) discovered in last 7 days - \(formattedRelativeUpdate(from: lastUpdate))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TrendMetric.allCases, id: \.self) { metric in
                        CVEFilterChip(
                            metric: metric,
                            count: countForMetric(metric),
                            isSelected: selectedCVEFilter == metric) {
                                withAnimation(.spring()) {
                                    selectedCVEFilter = metric
                                }
                            }
                    }
                }
            }

            if filteredCVEsForDisplay.isEmpty {
                emptyStateForMetric
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredCVEsForDisplay.prefix(10)) { cve in
                        SimpleCVECard(cve: cve)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }

    private var filteredCVEsForDisplay: [SimpleCVE] {
        let filtered: [SimpleCVE]

        switch selectedCVEFilter {
        case .vulnerabilities:
            filtered = trendsManager.allScoredCVEs
        case .critical:
            filtered = trendsManager.criticalCVEs
        case .high:
            filtered = trendsManager.highCVEs
        case .medium:
            filtered = trendsManager.mediumCVEs
        }
        return filtered
    }

    private func countForMetric(_ metric: TrendMetric) -> Int {
        switch metric {
        case .vulnerabilities:
            return trendsManager.allScoredCVEs.count
        case .critical:
            return trendsManager.criticalCVEs.count
        case .high:
            return trendsManager.highCVEs.count
        case .medium:
            return trendsManager.mediumCVEs.count
        }
    }

    private func colorForMetric(_ metric: TrendMetric) -> Color {
        switch metric {
        case .vulnerabilities:
            return themeManager.currentTheme.primary
        case .critical:
            return themeManager.currentTheme.dangerColor
        case .high:
            return themeManager.currentTheme.warningColor
        case .medium:
            return .yellow
        }
    }

    private var emptyStateForMetric: some View {
        VStack(spacing: 12) {
            Image(systemName: selectedCVEFilter == .vulnerabilities ? "checkmark.shield.fill" : "clock.badge.checkmark")
                .font(.system(size: 48))
                .foregroundStyle(colorForMetric(selectedCVEFilter))

            Text(emptyStateTitle)
                .font(.headline)
                .fontWeight(.semibold)

            Text(emptyStateMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    private var emptyStateTitle: String {
        switch selectedCVEFilter {
        case .vulnerabilities:
            return "No Scored CVEs Available"
        case .critical:
            return "No Critical Vulnerabilities"
        case .high:
            return "No High Severity Vulnerabilities"
        case .medium:
            return "No Medium Severity Vulnerabilities"
        }
    }

    private var emptyStateMessage: String {
        switch selectedCVEFilter {
        case .vulnerabilities:
            return "Recent CVEs are still being analyzed by NIST. Check back soon."
        case .critical:
            return "Good news! No critical severity vulnerabilities in the last 7 days."
        case .high:
            return "No high severity vulnerabilities reported recently."
        case .medium:
            return "No medium severity vulnerabilities reported recently."
        }
    }

    private var proUpgradePrompt: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [themeManager.currentTheme.warningColor, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
            }
            Text("Global Security Trends")
                .font(.title2)
                .fontWeight(.bold)

            Text("Track worldwide cybersecurity activity with real-time breach and vulnerability data.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                FeatureBullet(icon: "chart.bar.fill", text: "Real-time breach tracking", color: themeManager.currentTheme.warningColor)
                FeatureBullet(icon: "shield.fill", text: "CVE vulnerability monitoring", color: .red)
                FeatureBullet(icon: "clock.fill", text: "90-day trend history", color: themeManager.currentTheme.primary)
                FeatureBullet(icon: "lock.fill", text: "100% privacy-safe", color: themeManager.currentTheme.successColor)
            }
            .padding()
            .themedBackground(0.1)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("Upgrade to SecureState Pro")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [themeManager.currentTheme.warningColor, .yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 40)
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Global Threat Landscape")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .themedForeground(themeManager.currentTheme.primary)

                    if let lastUpdate = trendsManager.lastUpdateDate {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text("Updated \(lastUpdate.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    } else {
                        Text("No data yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
                // Info Button
                Button(action: {
                    showInfoSheet = true
                }) {
                    Image(systemName: "info.circle")
                }

                // refresh button
                if proManager.isPro {
                    Button(action: {
                        Task {
                            await trendsManager.manualRefresh(force: true)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .themedForeground(themeManager.currentTheme.primary)
                            .rotationEffect(.degrees(trendsManager.isLoading ? 360 : 0))
                            .animation(.linear(duration: 1).repeatCount(trendsManager.isLoading ? 100 : 1, autoreverses: false), value: trendsManager.isLoading)
                    }
                    .disabled(trendsManager.isLoading)
                }

                if let error = trendsManager.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .themedForeground(themeManager.currentTheme.warningColor)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(themeManager.currentTheme.warningColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .themedBackground(0.1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var metricsCardsSection: some View {
        VStack(spacing: 16) {
            MetricCard(
                icon: "exclamationmark.shield",
                title: "Total Vulnerabilities",
                subtitle: "Last 7 Days (Estimated)",
                value: trendsManager.currentVulnerabilityCount,
                color: themeManager.currentTheme.accent,
                isSelected: selectedCVEFilter == .vulnerabilities
            ) {
                selectedCVEFilter = .vulnerabilities

            }

            // Severity breakdown
            HStack(spacing: 12) {
                SeverityMiniCard(
                    title: "Critical",
                    count: trendsManager.currentCriticalCount,
                    color: themeManager.currentTheme.dangerColor,
                    isSelected: selectedCVEFilter == .critical
                ) {
                    selectedCVEFilter = .critical
                }

                SeverityMiniCard(
                    title: "High",
                    count: trendsManager.currentHighCount,
                    color: themeManager.currentTheme.warningColor,
                    isSelected: selectedCVEFilter == .high
                ) {
                    selectedCVEFilter = .high
                }

                SeverityMiniCard(
                    title: "Medium",
                    count: trendsManager.currentMediumCount,
                    color: .yellow,
                    isSelected: selectedCVEFilter == .medium
                ) {
                    selectedCVEFilter = .medium
                }
            }
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trend History")
                .font(.headline)
                .fontWeight(.semibold)

            if trendsManager.historicalData.isEmpty {
                EmptyChartPlaceHolder()
            } else {
                // Metric Selector
                Picker("Metric", selection: $selectedCVEFilter) {
                    ForEach(TrendMetric.allCases, id: \.self) { metric in
                        Text(metric.rawValue).tag(metric)
                    }
                }
                .pickerStyle(.segmented)

                // Chart
                TrendChart(
                    data: trendsManager.historicalData,
                    metric: selectedCVEFilter
                )
                .frame(height: 250)
            }
        }
        .padding()
        .cardStyle()
    }

    private var insightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Insight")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Text(trendsManager.getTrendInsight())
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        }
    }

    private var educationalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Understanding the Data")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                EducationRow(
                    icon: "shield.slash.fill",
                    title: "CVE (Common Vulnerabilities and Exposures)",
                    description: "Publicly disclosed security flaws in software that could be exploited by attackers."
                )

                EducationRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "Severity Levels",
                    description: "Critical = immediate action needed. High = urgent updates. Medium = important patches."
                )

                EducationRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Why This Matters",
                    description: "Rising numbers indicate increased threat activity. Keep your devices updated and stay vigilant."
                )
            }
        }
        .padding()
        .themedBackground(0.1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var attributionSection: some View {
        VStack(spacing: 8) {
            Text(trendsManager.sourceAttribution)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Link(destination: URL(string: "https://nvd.nist.gov")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.caption2)
                        Text("NVD")
                            .font(.caption2)
                    }
                }
            }
            .themedForeground(themeManager.currentTheme.primary)
        }
        .padding()
        .cardStyle()
    }

    private func formattedRelativeUpdate(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short // options: .full, .spellOut, etc.

        let now = Date()
        let interval = now.timeIntervalSince(date)

        if interval < 60 {
            return "Updated just now"
        } else {
            // this rounds to minute, hour, day, etc.
            return "Updated \(formatter.localizedString(for: date, relativeTo: now))"
        }
    }

}

#Preview {
    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let mockThemeManager = ThemeManager()
    let mockProManager = ProStatusManager(storeManager: EnhancedStoreManager())
    let mockAchievementsManager = AchievementsManager(modelContext: container.mainContext)

    SecurityTrendsView(modelContext: container.mainContext)
        .environmentObject(mockThemeManager)
        .environmentObject(mockProManager)
        .environmentObject(mockAchievementsManager)
        .modelContainer(container)
}
