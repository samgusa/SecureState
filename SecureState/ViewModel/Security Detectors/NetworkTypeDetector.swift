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

    }

    deinit {

    }

    private func startMonitoring() {

    }

    private func stopMonitoring() {

    }

    private func analyzeNetworkPath(_ path: Network.NWPath) {

    }

    private func determineNetworkType(from path: Network.NWPath) -> NetworkType {
        return .wifi
    }

    func checkNetworkType() {

    }

    func getSecurityScore() -> Int {
        return 1
    }

    func getComponentState() -> ComponentState {
        return .userOnly(score: 1)
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
        return true
    }

    var statusDisplayString: String {
        return ""
    }

    var scoreExplanation: String {
        return ""
    }

    


}
