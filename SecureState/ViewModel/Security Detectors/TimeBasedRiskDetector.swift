//
//  TimeBasedRiskDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/17/25.
//

import Foundation
import SwiftUI

class TimeBasedRiskDetector: ObservableObject {
    @Published var currentHour: Int = 0
    @Published var currentTimeRisk: TimeRiskLevel = .low
    @Published var lastChecked: Date = Date()

    private let maxScore: Int = 5
    private let calendar = Calendar.current

    enum TimeRiskLevel: String, CaseIterable {
        case low = "Low Risk"
        case medium = "Medium Risk"
        case high = "High Risk"

        var score: Int {
            switch self {
            case .low: return 5             // Full points
            case .medium: return 3          // Reduced points for moderate risk
            case .high: return 1            // very low points for high risk times
            }
        }

        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }

        var icon: String {
            switch self {
            case .low: return "sun.max"
            case .medium: return "moon"
            case .high: return "moon.zzz"
            }
        }

        var description: String {
            switch self {
            case .low: return "Normal hours - good alertness expected"
            case .medium: return "Early/late hours - reduced alertness possible"
            case .high: return "Very late/early hours - fatigue may affect security judgment"
            }
        }
    }

    init() {
        checkCurrentTime()

        // set up timer to check every hour
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.checkCurrentTime()
        }
    }

    func checkCurrentTime() {
        let now = Date()
        currentHour = calendar.component(.hour, from: now)
        currentTimeRisk = determineRiskLevel(for: currentHour)
        lastChecked = now
    }

    private func determineRiskLevel(for hour: Int) -> TimeRiskLevel {
        switch hour {
        case 23...23, 0...5: // 11 PM to 5:59 AM - High risk (very late/very early)
            return .high
        case 6...7, 21...22: // 6-7:59 AM and 9-10:59 PM - Medium risk (early/late)
            return .medium
        case 8...20:         // 8 AM to 8:59 PM - Low risk (normal hours)
            return .low
        default:
            return .medium
        }
    }

    func getSecurityScore() -> Int {
        return currentTimeRisk.score
    }

    func getComponentState() -> ComponentState {
        return .autoDetected(score: getSecurityScore(), confidence: .high)
    }

    // this component doesnt need user confirmation
    func needsUserConfirmation() -> Bool {
        return false
    }

    var timeDisplayString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    var riskExplanation: String {
        return "\(currentTimeRisk.rawValue) at \(timeDisplayString) - \(currentTimeRisk.description)"
    }

    var riskTimeRanges: String {
        switch currentTimeRisk {
        case .low:
            return "8:00 AM - 8:59 PM"
        case .medium:
            return "6:00 - 7:59 AM, 9:00 - 10:59 PM"
        case .high:
            return "11:00 PM - 5:59 AM"
        }
    }


}
