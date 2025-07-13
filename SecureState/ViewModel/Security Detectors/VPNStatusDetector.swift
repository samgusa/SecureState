//
//  VPNStatusDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 7/11/25.
//

import Foundation
import SwiftUI
import Network
import NetworkExtension

class VPNStatusDetector: ObservableObject {
    @Published var isVPNDetected: Bool = false
    @Published var detectionConfidence: ConfidenceLevel = .low
    @Published var isUserConfirmedVPN: Bool? = nil
    @Published var lastChecked: Date = Date()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "VPNMonitor")
    private let maxScore: Int = 15

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

        checkVPNStatus()
    }

    private func stopMonitoring() {
        monitor.cancel()
    }

    private func analyzeNetworkPath(_ path: Network.NWPath) {
        lastChecked = Date()

        // very basic interface check -- has limited reliability on iOS
        let hasVPNLikeInterface = checkForPossibleVPNInterface(path)

        if hasVPNLikeInterface {
            isVPNDetected = true
            detectionConfidence = .low // always low due to iOS limitations
        } else {
            isVPNDetected = false
            detectionConfidence = .medium
        }
    }

    private func checkForPossibleVPNInterface(_ path: Network.NWPath) -> Bool {
        // Simplified check - just look for non-standard interfaces
        let interfaces = path.availableInterfaces

        for interface in interfaces {
            if interface.type == .other {
                // might indicate a VPN, but could be many other things
                return true
            }
        }
        return false
    }

    func checkVPNStatus() {
        DispatchQueue.main.async { [weak self] in
            if let currentPath = self?.monitor.currentPath {
                self?.analyzeNetworkPath(currentPath)
            }
        }
    }

    func getSecurityScore() -> Int {
        // User confirmation takes priority due to detection limitations
        if let userConfirmed = isUserConfirmedVPN {
            return userConfirmed ? maxScore : 0
        }

        if isVPNDetected {
            return 3 // very conservative score for auto-detection
        } else {
            return 0
        }
    }

    func getComponentState() -> ComponentState {
        let autoScore = isVPNDetected ? 3 : 0
        if let userConfirmed = isUserConfirmedVPN {
            let finalScore = userConfirmed ? maxScore : 0
            return .userConfirmed(autoScore: autoScore, userScore: finalScore)
        } else {
            return .needsUserInput(
                autoScore: autoScore,
                reason: "VPN detection is limited on iOS - please confirm your VPN status for accurate scoring"
            )
        }
    }


    func confirmVPNActive() {
        isUserConfirmedVPN = true
    }

    func confirmNoVPN() {
        isUserConfirmedVPN = false
    }

    func resetUserConfirmation() {
        isUserConfirmedVPN = nil
    }

    func needsUserConfirmation() -> Bool {
        return isUserConfirmedVPN == nil
    }

    var statusDisplayString: String {
        if let userConfirmed = isUserConfirmedVPN {
            return userConfirmed ? "VPN Active (User Confirmed)" : "No VPN (User Confirmed)"
        }
        if isVPNDetected {
            return "Possible VPN Detected (Uncertain)"
        } else {
            return "No VPN Interface Found"
        }
    }


}
