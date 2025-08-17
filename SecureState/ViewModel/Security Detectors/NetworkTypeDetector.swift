//
//  NetworkTypeDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 7/11/25.
//

import Foundation
import SwiftUI
import Network
import NetworkExtension


class NetworkTypeDetector: ObservableObject {
    @Published var currentNetworkType: NetworkType = .unknown
    @Published var isUserConfirmedSafe: Bool? = nil
    @Published var lastChecked: Date = Date()
    @Published var detectionConfidence: ConfidenceLevel = .medium

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkTypeMonitor")
    private let maxScore: Int = 10

    enum NetworkType: String, CaseIterable {
        case wifi = "Wi-Fi"
        case cellular = "Cellular"
        case ethernet = "Ethernet"
        case unknown = "Unknown"

        var baseSecurityScore: Int {
            switch self {
            case .cellular: return 8
            case .ethernet: return 7
            case .wifi: return 3
            case .unknown: return 0
            }
        }

        var icon: String {
            switch self {
            case .wifi: return "wifi"
            case .cellular: return "antenna.radiowaves.left.and.right"
            case .ethernet: return "cable.connector"
            case .unknown: return "questionmark.circle"
            }
        }

        var requiresUserConfirmation: Bool {
            switch self {
            case .wifi: return true
            case .cellular: return false
            case .ethernet: return true
            case .unknown: return true
            }
        }
    }

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.analyzeNetworkPath(path)
            }
        }
        monitor.start(queue: queue)

        checkNetworkType()
    }

    private func stopMonitoring() {
        monitor.cancel()
    }

    private func analyzeNetworkPath(_ path: Network.NWPath) {
        lastChecked = Date()

        // determine network type from available interfaces
        let newNetworkType = determineNetworkType(from: path)

        if newNetworkType != currentNetworkType {
            currentNetworkType = newNetworkType

            // reset user confirmation when network type changes
            if newNetworkType.requiresUserConfirmation {
                isUserConfirmedSafe = nil
            }
        }

        // set confidence based on detection reliability
        detectionConfidence = newNetworkType == .unknown ? .low : .high
    }

    private func determineNetworkType(from path: Network.NWPath) -> NetworkType {
        // check interface types in order of preference
        let interfaces = path.availableInterfaces

        for interface in interfaces {
            switch interface.type {
            case .wifi:
                return .wifi
            case .cellular:
                return .cellular
            case .wiredEthernet:
                return .ethernet
            case .other, .loopback:
                // MARK: Figure out what this continue means in a switch and the other stuff below.
                continue
            @unknown default:
                continue
            }
        }
        return .unknown
    }

    func checkNetworkType() {
        DispatchQueue.main.async { [weak self] in
            if let currentPath = self?.monitor.currentPath {
                self?.analyzeNetworkPath(currentPath)
            }
        }
    }

    func getSecurityScore() -> Int {
        let baseScore = currentNetworkType.baseSecurityScore

        // Apply user confirmation if network type requires it
        if currentNetworkType.requiresUserConfirmation {
            if let userConfirmed = isUserConfirmedSafe {
                return userConfirmed ? maxScore : 2 // Very low score for confirmed unsafe networks
            } else {
                return baseScore
            }
        }
        return baseScore
    }

    func getComponentState() -> ComponentState {
        let autoScore = currentNetworkType.baseSecurityScore

        if currentNetworkType.requiresUserConfirmation {
            if let userConfirmed = isUserConfirmedSafe {
                let finalScore = userConfirmed ? maxScore : 2
                return .userConfirmed(autoScore: autoScore, userScore: finalScore)
            } else {
                return .needsUserInput(
                    autoScore: autoScore,
                    reason: "Please confirm if this \(currentNetworkType.rawValue) network is trusted"
                )
            }
        } else {
            return .autoDetected(score: autoScore, confidence: detectionConfidence)
        }
    }

    func confirmNetworkSafe() {
        isUserConfirmedSafe = true
    }

    func confirmNetworkUnsafe() {
        isUserConfirmedSafe = false
    }

    func resetUserConfirmation() {
        isUserConfirmedSafe = nil
    }

    func needsUserConfirmation() -> Bool {
        return currentNetworkType.requiresUserConfirmation && isUserConfirmedSafe == nil
    }

    var statusDisplayString: String {
        let baseStatus = "Connected via \(currentNetworkType.rawValue)"

        if let userConfirmed = isUserConfirmedSafe {
            let safteyStatus = userConfirmed ? "(Trusted)" : "(Untrusted)"
            return "\(baseStatus) \(safteyStatus)"
        }

        if currentNetworkType.requiresUserConfirmation {
            return "\(baseStatus) (Needs Confirmation)"
        }
        return baseStatus
    }

    var scoreExplanation: String {
        let currentScore = getSecurityScore()
        let baseScore = currentNetworkType.baseSecurityScore

        if let userConfirmed = isUserConfirmedSafe {
            if userConfirmed {
                return "Trusted \(currentNetworkType.rawValue) network (\(maxScore)/\(maxScore))"
            } else {
                return "Untrusted network - high risk (2/\(maxScore))"
            }
        }
        if currentNetworkType.requiresUserConfirmation {
            return "Auto-detected: \(baseScore)/\(maxScore)) - confirmed network safety for full assessment"
        }
        return "\(currentNetworkType.rawValue): \(currentScore)/\(maxScore)"
    }

    


}
