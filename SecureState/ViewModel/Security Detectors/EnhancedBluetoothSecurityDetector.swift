//
//  EnhancedBluetoothSecurityDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/10/25.
//

import Foundation
import SwiftUI
import CoreBluetooth

// MARK: Enhanced Bluetooth Security Detector
class EnhancedBluetoothSecurityDetector: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var nearbyDevices: [BluetoothDeviceInfo] = []
    @Published var isScanning: Bool = false
    @Published var bluetoothEnabled: Bool = false
    @Published var userEnvironmentConfirmation: EnvironmentSafety?
    @Published var lastScanTime: Date?
    @Published var hasScannedOnce: Bool = false // Trach if we've done any scan

    private var centralManager: CBCentralManager!
    private var scanTimer: Timer?
    private let scanDuration: TimeInterval = 10.0

    // MARK: Device Processing Queue
    private let deviceProcessingQueue = DispatchQueue(label: "bluetooth.device.processing", qos: .userInitiated)
    private var pendingDeviceUpdates: [BluetoothDeviceInfo] = []
    private var batchUpdateTimer: Timer?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    enum EnvironmentSafety {
        case safe, caution, unsafe

        var score: Int {
            switch self {
            case .safe: return 5
            case .caution: return 3
            case .unsafe: return 1
            }
        }
    }

    // Cache Management
    func clearCache() {
        nearbyDevices.removeAll()
        userEnvironmentConfirmation = nil
        hasScannedOnce = false
        lastScanTime = nil
        pendingDeviceUpdates.removeAll()

        // cancel any pending timers
        batchUpdateTimer?.invalidate()
        scanTimer?.invalidate()

        if isScanning {
            stopScanning()
        }
        objectWillChange.send()
    }

    // MARK: Batch processing for smoothUI
    private func processPendingDeviceUpdates() {
        guard !pendingDeviceUpdates.isEmpty else { return }

        let updates = pendingDeviceUpdates
        pendingDeviceUpdates.removeAll()

        // Process all updates on background queue
        deviceProcessingQueue.async { [weak self] in
            guard let self = self else { return }

            var updatedDevices = self.nearbyDevices

            for update in updates {
                if let existingIndex = updatedDevices.firstIndex(where: { $0.peripheral.identifier == update.peripheral.identifier }) {
                    updatedDevices[existingIndex] = update
                } else {
                    updatedDevices.append(update)
                }
            }

            // Update UI on main Queue with completed batch
            DispatchQueue.main.async {
                self.nearbyDevices = updatedDevices
            }
        }
    }

    func startScanning() {
        guard bluetoothEnabled else { return }

        isScanning = true
        nearbyDevices.removeAll()
        lastScanTime = Date()
        hasScannedOnce = true

        centralManager.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])

        // Stop scanning after duration
        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(withTimeInterval: scanDuration, repeats: false) { _ in
            self.stopScanning()
        }
    }

    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
        scanTimer?.invalidate()

        batchUpdateTimer?.invalidate()
        processPendingDeviceUpdates()
    }

    func confirmEnvironmentSafety(_ safety: EnvironmentSafety) {
        userEnvironmentConfirmation = safety
        objectWillChange.send()
    }

    func needsUserConfirmation() -> Bool {
        guard bluetoothEnabled else { return false }
        // If we've completed a scan (either auto or manual) but no user confirmation
        return !hasScannedOnce || lastScanTime != nil && userEnvironmentConfirmation == nil
    }

    func checkCurrentState() {
        objectWillChange.send()
    }

    func getSecurityScore() -> Int {
        // If bluetooth is disabled, maximum security
        guard bluetoothEnabled else { return 5 }

        // if user has confirmed environment safety, use that
        if let userConfirmation = userEnvironmentConfirmation {
            return userConfirmation.score
        }

        // If we haven't scanned yet, return neutral score but flag for attention
        guard hasScannedOnce else { return 1 }

        // Calculate base score from scan results.
        return calculateBaseScore()
    }

    private func calculateBaseScore() -> Int {
        let suspiciousCount = nearbyDevices.filter { $0.isSuspicious }.count
        let highRiskCount = nearbyDevices.filter { $0.riskLevel == .high }.count

        // Base scoring logic
        if highRiskCount > 0 { return 0 }
        if suspiciousCount > 2 { return 1 }

        return 4
    }

    var environmentalContext: String {
        let deviceCount = nearbyDevices.count

        if deviceCount == 0 {
            return "No Bluetooth devices detected"
        } else {
            return "\(deviceCount) Bluetooth device\(deviceCount == 1 ? "" : "s") detected"
        }
    }

    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothEnabled = central.state == .poweredOn
        objectWillChange.send()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        let deviceInfo = BluetoothDeviceInfo(
            peripheral: peripheral,
            rssi: RSSI.intValue,
            advertisementData: advertisementData,
            discoveredAt: Date()
        )

        // add pending updates for batch processing
        pendingDeviceUpdates.append(deviceInfo)

        // start or reset batch timer
        batchUpdateTimer?.invalidate()
        batchUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            self.processPendingDeviceUpdates()
        })
    }

}
