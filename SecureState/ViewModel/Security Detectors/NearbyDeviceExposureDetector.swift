//
//  NearbyDeviceExposureDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/17/25.
//

import Foundation
import SwiftUI
import CoreLocation
import CoreBluetooth

class NearbyDeviceExposureDetector: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var isBluetoothEnabled: Bool = false
    @Published var connectedAccessories: [String] = []
    @Published var hasConnectedAccessories: Bool = false
    @Published var userConfirmedAccessoryUse: Bool? = nil
    @Published var lastChecked: Date = Date()
    @Published var detectionConfidence: ConfidenceLevel = .medium

    // reference location context for cross checking environment
    @Published var isInPublicSpace: Bool = false

    private var centralManager: CBCentralManager?
    private let maxScore: Int = 5

    enum BluetoothRiskLevel: String, CaseIterable {
        case bluetoothOff = "Bluetooth Off"
        case privateWithBluetooth = "Bluetooth on (Private)"
        case publicWithAccessory = "Bluetooth On + Accessory (Public)"
        case publicNoAccessory = "Bluetooth On (Public)"

        var score: Int {
            switch self {
            case .bluetoothOff: return 5
            case .privateWithBluetooth: return 4
            case .publicWithAccessory: return 3
            case .publicNoAccessory: return 1
            }
        }

        var color: Color {
            switch self {
            case .bluetoothOff: return .green
            case .privateWithBluetooth: return .green
            case .publicWithAccessory: return .orange
            case .publicNoAccessory: return .red
            }
        }

        var icon: String {
            switch self {
            case .bluetoothOff: return "antenna.radiowaves.left.and.right.slash"
            case .privateWithBluetooth: return "antenna.radiowaves.left.and.right"
            case .publicWithAccessory: return "headphones"
            case .publicNoAccessory: return "exclamationmark.triangle"
            }
        }

        var description: String {
            switch self {
            case .bluetoothOff: return "Device not discovered - minimal wireless exposure"
            case .privateWithBluetooth: return "Bluetooth enabled in trusted environment"
            case .publicWithAccessory: return "Justified Bluetooth use with connected accessory"
            case .publicNoAccessory: return "Unnecessary Bluetooth exposure in public space"
            }
        }
    }

    override init() {
        super.init()
        setupBluetoothMonitoring()
    }

    private func setupBluetoothMonitoring() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async { [weak self] in
            self?.bluetoothState = central.state
            self?.isBluetoothEnabled = (central.state == .poweredOn)
            self?.lastChecked = Date()
            self?.updateDetectionConfidence()
            self?.checkForConnectedAccessories()
        }
    }

    private func updateDetectionConfidence() {
        // High confidence for bluetooth state detection
        // medium confidence overall because we cant always detect all accessories.
        detectionConfidence = isBluetoothEnabled ? .medium : .high
    }

    private func checkForConnectedAccessories() {
        // Note: iOS sandbox limitations means we cant always detect all connected devices
        // This is a simplified check - in a real implementation, you might use
        // AVAudioSession or other APIs to detect audio accessories

        // For now, we'll rely on user confirmation for accessory detection
        // since iOS doesnt provide reliable APIs for this in sandbox mode
        hasConnectedAccessories = false
        connectedAccessories = []
    }

    func updateLocationContext(isPublic: Bool) {
        isInPublicSpace = isPublic
    }

    func getCurrentRiskLevel() -> BluetoothRiskLevel {
        if !isBluetoothEnabled {
            return .bluetoothOff
        }

        if !isInPublicSpace {
            return .privateWithBluetooth
        }

        if let userConfirmed = userConfirmedAccessoryUse {
            return userConfirmed ? .publicWithAccessory : .publicNoAccessory
        }
        // Fallback passed on detected accessories
        return hasConnectedAccessories ? .publicWithAccessory : .publicNoAccessory
    }

    func getSecurityScore() -> Int {
        return getCurrentRiskLevel().score
    }

    func getComponentState() -> ComponentState {
        let currentRisk = getCurrentRiskLevel()
        let autoScore = currentRisk.score

        // If bluetooth is on and we're in public, might need user confirmation about accessories
        if isBluetoothEnabled && isInPublicSpace && userConfirmedAccessoryUse == nil {
            return .needsUserInput(
                autoScore: autoScore,
                reason: "Please confirm if you're using Bluetooth accessories (Airpods, headphones, etc.)"
            )
        }

        if let userConfirmed = userConfirmedAccessoryUse {
            let finalScore = userConfirmed ? BluetoothRiskLevel.publicWithAccessory.score : BluetoothRiskLevel.publicNoAccessory.score
            return .userConfirmed(autoScore: autoScore, userScore: finalScore)
        }
        return .autoDetected(score: autoScore, confidence: detectionConfidence)
    }

    func confirmAccessoryUse() {
        userConfirmedAccessoryUse = true
    }

    func confirmedNoAccesorryUse() {
        userConfirmedAccessoryUse = false
    }

    func resetUserConfirmation() {
        userConfirmedAccessoryUse = nil
    }

    func  needsUserConfirmation() -> Bool {
        // Need user confirmation when:
        // 1. Bluetooth is enabled
        // 2: we're in a public space (high risk scenario)
        // 3: User hasn't confirmed accessory usage yet
        return isBluetoothEnabled && isInPublicSpace && userConfirmedAccessoryUse == nil
    }

    func checkCurrentState() {
        lastChecked = Date()
        // Trigger a state update if needed
        if let central = centralManager {
            centralManagerDidUpdateState(central)
        }

    }

    var statusDisplayString: String {
        let currentRisk = getCurrentRiskLevel()

        if let userConfirmed = userConfirmedAccessoryUse {
            let accessoryStatus = userConfirmed ? "with accessories" : "no accessories"
            return "\(currentRisk.rawValue) (\(accessoryStatus))"
        }

        if needsUserConfirmation() {
            return "\(currentRisk.rawValue) (Needs Confirmation)"
        }
        return currentRisk.rawValue
    }

    var scoreExplanation: String {
        let currentRisk = getCurrentRiskLevel()
        let score = getSecurityScore()
        return "\(currentRisk.description) (\(score)/\(maxScore) points)"
    }

    var recommendAction: String {
        let currentRisk = getCurrentRiskLevel()
        switch currentRisk {
        case .bluetoothOff: return "Bluetooth is off - optimal privacy setting"
        case .privateWithBluetooth: return "Good - Bluetooth risk is low in private spaces"
        case .publicWithAccessory: return "Consider disabling Bluetooth when accessories aren't needed"
        case .publicNoAccessory: return "Recommendation: Turn off Bluetooth to reduce exposure risk"
        }
        return ""
    }




}
