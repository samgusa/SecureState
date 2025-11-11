//
//  TrendChart.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import SwiftUI
import Charts
import SwiftData

struct TrendChart: View {
    @EnvironmentObject var themeManager: ThemeManager
    let data: [TrendDataPoint]
    let metric: SecurityTrendsView.TrendMetric

    var body: some View {
        Chart {
            ForEach(data) { point in
                switch metric {
                case .vulnerabilities:
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Count", point.vulnerabilityCount)
                    )
                    .foregroundStyle(themeManager.currentTheme.accent)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Count", point.vulnerabilityCount)
                    )
                    .foregroundStyle(themeManager.currentTheme.accent.opacity(0.1))
                    .interpolationMethod(.catmullRom)

                case .critical:
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Count", point.criticalCount)
                    )
                    .foregroundStyle(themeManager.currentTheme.dangerColor)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Count", point.criticalCount)
                    )
                    .foregroundStyle(themeManager.currentTheme.dangerColor.opacity(0.1))
                    .interpolationMethod(.catmullRom)

                case .high:
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Count", point.highCount)
                    )
                    .foregroundStyle(themeManager.currentTheme.warningColor)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Count", point.highCount)
                    )
                    .foregroundStyle(themeManager.currentTheme.warningColor.opacity(0.1))
                    .interpolationMethod(.catmullRom)

                case .medium:
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Count", point.mediumCount)
                    )
                    .foregroundStyle(.yellow)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Count", point.mediumCount)
                    )
                    .foregroundStyle(.yellow.opacity(0.1))
                    .interpolationMethod(.catmullRom)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartXAxisLabel("Date")
        .chartYAxisLabel("Vulnerability Count")
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
