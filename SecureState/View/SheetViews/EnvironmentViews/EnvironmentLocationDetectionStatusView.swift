//
//  EnvironmentLocationDetectionStatusView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/25/25.
//

import SwiftUI
import SwiftData

struct EnvironmentLocationDetectionStatusView: View {
    @ObservedObject var detector: EnvironmentalSecurityDetector
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(detector.detectionConfidence.color)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Detection: \(detector.detectionConfidence.level)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(detector.detectionConfidence.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if detector.hasLocationPermission {
                    Button("Refresh Location") {
                        detector.performLocationSnapshot()
                    }
                    .font(.caption)
                    .themedForeground(themeManager.currentTheme.primary)
                } else {
                    Button("Enable Location") {
                        detector.requestLocationPermission()
                    }
                    .font(.caption)
                    .themedForeground(themeManager.currentTheme.primary)
                }
            }
            
            if let suggestion = detector.smartSuggestion {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .themedForeground(themeManager.currentTheme.primary)

                    Text("Suggestion: \(suggestion.displayName)")
                        .font(.subheadline)
                        .themedForeground(themeManager.currentTheme.primary)

                    Spacer()
                    
                    Button("Use") {
                        detector.selectEnvironmentType(suggestion)
                    }
                    .font(.caption)
                    .themedForeground(themeManager.currentTheme.primary)
                }
                .padding()
                .background(themeManager.currentTheme.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
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
        
        return EnvironmentLocationDetectionStatusView(detector: EnvironmentalSecurityDetector())
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
        
        return EnvironmentLocationDetectionStatusView(detector: EnvironmentalSecurityDetector())
            .environmentObject(proManager)
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
    }()
    return view
}
