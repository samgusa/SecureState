//
//  NetworkSecurityDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/16/25.
//

import Foundation
import Network
import NetworkExtension

class NetworkSecurityDetector: ObservableObject {
    @Published var currentNetworkName: String = ""
    @Published var isOnWiFi: Bool = false
    @Published var isUserConfirmedTrusted: Bool? = nil
    @Published var connectionType: ConnectionType = .unknown

    private let maxScore: Int = 20
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    enum ConnectionType {
        case cellular
        case trustedWiFi
        case unknownWiFi
        case publicWiFi
        case openWiFi
        case unknown

        var baseScore: Int {
            switch self {
            case .cellular: return 20
            case .trustedWiFi: return 18
            case .unknownWiFi: return 10
            case .publicWiFi: return 3
            case .openWiFi: return 0
            case .unknown: return 10
            }
        }

        var description: String {
            switch self {
            case .cellular: return "Cellular Connection"
            case .trustedWiFi: return "Trusted Wi-Fi"
            case .unknownWiFi: return "Unknown Wi-Fi"
            case .publicWiFi: return "Public Wi-Fi"
            case .openWiFi: return "Open/Unsecured Wi-Fi"
            case .unknown: return "Unknown Network"
            }
        }

        var riskLevel: String {
            switch self {
            case .cellular: return "Minimal Risk"
            case .trustedWiFi: return "Low Risk"
            case .unknownWiFi: return "Medium Risk"
            case .publicWiFi: return "High Risk"
            case .openWiFi: return "Very High Risk"
            case .unknown: return "Unknown Risk"
            }
        }
    }

    init() {
        startMonitoring()
    }

    deinit {
        monitor.cancel()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateNetworkStatus(path: path)
            }
        }
        monitor.start(queue: queue)
    }

    private func updateNetworkStatus(path: Network.NWPath) {
        isOnWiFi = path.usesInterfaceType(.wifi)

        if isOnWiFi {
            detectNetworkName()
            assessNetworkRisk()
        } else {
            connectionType = .cellular
            currentNetworkName = "Cellular"
        }
    }

    private func detectNetworkName() {
        // try to get wi-fi network name (SSID)
        // cant reliably get SSID without special entitlements
        currentNetworkName = "Wi-Fi Network"

    }

    private func assessNetworkRisk() {
        guard isOnWiFi else {
            connectionType = .cellular
            return
        }

        // Since we can't reliably get network name, we'll default to unknown
        // this puts decision in the user's hands, which is more honest
        // about out detection capabilities
        return connectionType = .unknownWiFi
    }

    func getSecurityScore() -> Int {
        // If not wi-fi, full score (no wi-fi risk)
        guard isOnWiFi else { return maxScore }

        // If user has confirmed safety, use that
        if let userConfirmed = isUserConfirmedTrusted {
            return userConfirmed ? 18 : 5
        }
        // Otherwise use auto-detected risk level
        return connectionType.baseScore
    }

    func getComponentState() -> ComponentState {
        guard isOnWiFi else {
            return .autoDetected(score: maxScore, confidence: .high)
        }
        let autoScore = connectionType.baseScore

        if let userConfirmed = isUserConfirmedTrusted {
            let finalScore = userConfirmed ? 18 : 5
            return .userConfirmed(autoScore: autoScore, userScore: finalScore)
        } else {
            let confidence: ConfidenceLevel = connectionType == .unknownWiFi ? .low : .medium
            return .autoDetected(score: autoScore, confidence: confidence)
        }
    }

    func confirmedNetworkTrusted() {
        isUserConfirmedTrusted = true
    }

    func confirmedNetworkPublic() {
        isUserConfirmedTrusted = false
    }

    func resetUserConfirmation() {
        isUserConfirmedTrusted = nil
    }

    func needsUserConfirmation() -> Bool {
        return isOnWiFi && (connectionType == .unknownWiFi || isUserConfirmedTrusted == nil)
    }

    var statusDescription: String {
        guard isOnWiFi else { return "Cellular Connection - Private tunnel to carrier" }

        if let userConfirmed = isUserConfirmedTrusted {
            return userConfirmed ? "Confirmed Trusted Network" : "Confirmed Public Network"
        }

        return connectionType.description
    }

    var scoreExplanation: String {
        guard isOnWiFi else { return "Cellular connection (\(maxScore)/\(maxScore))" }

        let autoScore = connectionType.baseScore

        if let userConfirmed = isUserConfirmedTrusted {
            if userConfirmed {
                return "User confirmed trusted network (18/\(maxScore))"
            } else {
                return "User confirmed public network (3/\(maxScore))"
            }
        } else {
            return "Auto-detected: \(connectionType.description) (\(autoScore)/\(maxScore))"
        }
    }

    var networkSecurityAdvice: String {
        guard isOnWiFi else {
            return "Cellular provides a private connection through your carrier with minimal risk."
        }

        if let userConfirmed = isUserConfirmedTrusted {
            if userConfirmed {
                return "Trusted networks are controlled by you or your organization, reducing risk from unknown users."
            } else {
                return "Public networks are shared with strangers who could potentially monitor traffic or discover your device."

            }
        }
        return "Consider who else has access to this network and whether you trust them with your device's presence."
    }

}
