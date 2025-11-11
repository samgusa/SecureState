//
//  ScoreCardView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI
import SwiftData

struct ScoreCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var proManager: ProStatusManager
    @EnvironmentObject var achievementsManager: AchievementsManager
    @Binding var animateScore: Bool
    @Binding var badgeRefreshTrigger: Bool
    var overallPercentage: Double
    var overallScoreColor: Color
    var securityStatusMessage: String
    var securityStatusColor: Color
    var totalScore: Double
    var totalMaxScore: Int
    var securityAdvice: String


    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Score circle visualization
                ZStack {
                    Circle()
                        .stroke(themeManager.currentTheme.primary.opacity(0.2), lineWidth: 10)
                        .frame(width: 90, height: 90)

                    Circle()
                        .trim(from: 0, to: animateScore ? overallPercentage: 0)
                        .stroke(overallScoreColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.5).delay(0.8), value: animateScore)

                    VStack(spacing: 2) {
                        Text("\(Int(overallPercentage * 100))")
                            .contentTransition(.numericText())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(overallScoreColor)
                            .monospacedDigit()

                        Text("%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(securityStatusMessage)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(securityStatusColor)

                    Text("Current protection level")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(Int(totalScore))/\(Int(totalMaxScore)) points")
                        .contentTransition(.numericText())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                if let badge = achievementsManager.selectedBadge {
                    SelectedBadgeDisplay(achievement: badge)
                        .id("\(badge.id)-\(badgeRefreshTrigger)")
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Color.clear
                        .frame(width: 32, height: 32)
                        .id("no-badge-\(badgeRefreshTrigger)")
                }
            }
            // Security advice based on score
            if overallPercentage < 0.7 {
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(themeManager.currentTheme.warningColor)

                    Text(securityAdvice)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .cardStyle(overallScoreColor)
        .animation(.spring(), value: achievementsManager.selectedBadge?.id)
        .id("score-card-\(badgeRefreshTrigger)")
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

        return VStack {
            ScoreCardView(
                animateScore: .constant(true),
                badgeRefreshTrigger: .constant(true),
                overallPercentage: 0.8,
                overallScoreColor: .green,
                securityStatusMessage: "Good Protection",
                securityStatusColor: .mint,
                totalScore: 69,
                totalMaxScore: 100,
                securityAdvice: ""
            )
            .padding(.bottom, 15)
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
            .environmentObject(mockStoreManager)
            .environmentObject(freeProManager)


            ScoreCardView(
                animateScore: .constant(true),
                badgeRefreshTrigger: .constant(true),
                overallPercentage: 0.5,
                overallScoreColor: .red,
                securityStatusMessage: "Not Protected",
                securityStatusColor: .red,
                totalScore: 49,
                totalMaxScore: 100,
                securityAdvice: "Focus on device security - enable VPN and update iOS"
            )
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
            .environmentObject(mockStoreManager)
            .environmentObject(freeProManager)
        }
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

        return VStack {
            ScoreCardView(
                animateScore: .constant(true),
                badgeRefreshTrigger: .constant(true),
                overallPercentage: 0.8,
                overallScoreColor: .green,
                securityStatusMessage: "Good Protection",
                securityStatusColor: .mint,
                totalScore: 69,
                totalMaxScore: 100,
                securityAdvice: ""
            )
            .padding(.bottom, 15)
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
            .environmentObject(mockStoreManager)
            .environmentObject(proManager)

            ScoreCardView(
                animateScore: .constant(true),
                badgeRefreshTrigger: .constant(true),
                overallPercentage: 0.5,
                overallScoreColor: .red,
                securityStatusMessage: "Not Protected",
                securityStatusColor: .red,
                totalScore: 49,
                totalMaxScore: 100,
                securityAdvice: "Focus on device security - enable VPN and update iOS"
            )
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
            .environmentObject(mockStoreManager)
            .environmentObject(proManager)
        }
    }()
    return view
}
