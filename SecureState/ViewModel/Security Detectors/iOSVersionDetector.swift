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

    private let maxScore: Int = 15

    init() {
        detectCurrentVersion()
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
    private func calculateAutoScore() -> Int {
        let (minor, major, _) = versionComponents

        // iOS 18+ version gets higher base score
        var score: Int = 0

        if major >= 18 { score = 8 } else if major >= 16 {
            score = 6
        } else if major >= 14 {
            score = 4
        } else {
            score = 2
        }
        if minor >= 2 {
            score = min(score + 1, 9) // cap at 9 for auto detection
        }
        return score
    }

    func getSecurityScore() -> Int {
        let autoScore = calculateAutoScore()

        // if user has confirmed, use that info
        if let userConfirmed = isUserConfirmedLatest {
            if userConfirmed {
                return maxScore
            } else {
                return max(autoScore - 2, 2)
            }
        }
        return autoScore
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

    func confirmlatestVersion() {
        isUserConfirmedLatest = true
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

    var isModernVersion: Bool {
        return versionComponents.major >= 16
    }

    var scoreExplanation: String {
        let autoScore = calculateAutoScore()

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

