//
//  iOSVersionDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 7/10/25.
//

import SwiftUI
import Foundation

class iOSVersionDetector: ObservableObject {
    @Published var currentVersion: String = ""
    @Published var versionComponents: (major: Int, minor: Int, patch: Int) = (0, 0, 0)
    @Published var isUserConfirmedLatest: Bool? = nil
    @Published var lastConfirmationDate: Date?

    let maxScore: Int = 15

    init() {
        detectCurrentVersion()
    }

    var expectedVersionDisplay: Int {
        let expected = getExpectedMajorVersion()

        return (expected % 100)
    }

    private func detectCurrentVersion() {
        currentVersion = UIDevice.current.systemVersion
        versionComponents = parseVersion(currentVersion)
    }

    private func parseVersion(_ versionString: String) -> (major: Int, minor: Int, patch: Int) {
        let components = versionString.split(separator: ".").compactMap({ Int($0)} )
        let major = components.count > 0 ? components[0] : 0
        let minor = components.count > 1 ? components[1] : 0
        let patch = components.count > 2 ? components[2] : 0
        return (major, minor, patch)
    }

    // Auto-detecting scoring based on version patterns
    func calculateAutoScore() -> Int {
        let (major, _, _) = versionComponents
        let expectedVersion = getExpectedMajorVersion()

        // Normalize expected version to iOS version format (e.g., 2026 → 26)
        let normalizedExpected = expectedVersion >= 100 ? expectedVersion % 100 : expectedVersion

        // iOS 18+ version gets higher base score
        var score: Int = 0

        // Calculate how far behind the expecteed version we are
        let versionData = normalizedExpected - major

        switch versionData {
        case 0:
            // current year's version
            score = 12
        case 1:
            // One year behind
            score = 10
        case 2:
            // two years behind
            score = 6
        default:
            // three or more years behind
            score = max(1, 7 - versionData)
        }
        return score
    }

    func getExpectedMajorVersion() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)

        // iOS Version 18 was released in 2024
        // starting 2025, version matches year: iOS 26 for 2025
        if year >= 2025 {
            return month >= 9 ? year + 1 : year
        }

        if year == 2024 {
            return month >= 9 ? 18 : 17
        }
        return 17
    }

    func getSecurityScore() -> Int {
        let autoScore = calculateAutoScore()

        // scale auto score in 15-point system
        let versionScore = autoScore

        var confirmationBonus = 0

        // if user has confirmed, use that info
        if let userConfirmed = isUserConfirmedLatest, let confirmData = lastConfirmationDate {
            let daysSince = Calendar.current.dateComponents([.day], from: confirmData, to: Date()).day ?? 0

            if userConfirmed {
                // degrade score over time since last confirmation
                switch daysSince {
                case 0..<30: confirmationBonus = 3    // Fresh confirmation
                case 30..<60: confirmationBonus = 2   // 1-2 months old
                case 60..<90: confirmationBonus = 1   // 2-3 months old
                default: confirmationBonus = 0        // Stale confirmation
                }
            } else {
                confirmationBonus = -2
            }
        }
        return max(0, min(versionScore + confirmationBonus, maxScore))
    }

    func getComponentState() -> ComponentState {
        let autoScore = calculateAutoScore()

        if let userConfirmed = isUserConfirmedLatest {
            let finalScore = userConfirmed ? maxScore : max(autoScore - 2, 2)
            return .userConfirmed(autoScore: autoScore, userScore: finalScore)
        } else {
            return .autoDetected(score: autoScore, confidence: .medium)
        }
    }

    func confirmLatestVersion() {
        isUserConfirmedLatest = true
        lastConfirmationDate = Date()
    }

    func confirmUpdateAvailable() {
        isUserConfirmedLatest = false
    }

    func resetUserConfirmation() {
        isUserConfirmedLatest = nil
    }

    func needsUserConfirmation() -> Bool {
        return isUserConfirmedLatest == nil
    }

    var versionDisplayString: String {
        return "iOS \(currentVersion)"
    }

    var daysSinceLastConfirmation: Int {
        guard let confirmDate = lastConfirmationDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: confirmDate, to: Date()).day ?? 0
    }

    var scoreExplanation: String {
        let autoScore = getSecurityScore()

        if let userConfirmed = isUserConfirmedLatest {
            if userConfirmed {
                return "Latest version confirmed (\(maxScore)/\(maxScore))"
            } else {
                return "Update available - auto: \(autoScore), current: \(getSecurityScore())"
            }
        } else {
            return "Auto-detected: \(autoScore)/\(maxScore) - confirmed if latest for full score"
        }
    }

}

