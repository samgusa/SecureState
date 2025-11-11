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
    @Published var isScanning = false
    @Published var bluetoothEnabled = false
    @Published var userEnvironmentConfirmation: EnvironmentSafety?
    @Published var lastScanTime: Date?
    @Published var hasScannedOnce: Bool = false // Track if we've done any scan

    private var centralManager: CBCentralManager!
    private var scanTimer: Timer?
    // MARK: Testing
    private let scanDuration: TimeInterval = 5.0

    // MARK: Device Processing Queue
    private let deviceProcessingQueue = DispatchQueue(label: "bluetooth.device.processing", qos: .userInitiated)
    private var pendingDeviceUpdates: [BluetoothDeviceInfo] = []
    private var batchUpdateTimer: Timer?

    enum EnvironmentSafety: String {
        case safe = "safe"
        case caution = "caution"
        case unsafe = "unsafe"

        var score: Int {
            switch self {
            case .safe: return 15
            case .caution: return 8
            case .unsafe: return 3
            }
        }

        var description: String {
            switch self {
            case .safe: return "Safe Environment"
            case .caution: return "Cautious Environment"
            case .unsafe: return "Unsafe Environment"
            }
        }
    }

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    deinit {
        batchUpdateTimer?.invalidate()
        scanTimer?.invalidate()
        centralManager.stopScan()
    }


    // Cache Management
    func clearCache() {
        nearbyDevices.removeAll()
        userEnvironmentConfirmation = nil
        hasScannedOnce = false
        lastScanTime = nil
        pendingDeviceUpdates.removeAll()

        // Cancel any pending timers
        batchUpdateTimer?.invalidate()
        scanTimer?.invalidate()

        // Stop scanning if in progress
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

        // process all updates on background queue
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

            // Update UI on main queue with completed batch
            DispatchQueue.main.async {
                self.nearbyDevices = updatedDevices
            }
        }
    }

    func resetDeviceList() {
        nearbyDevices.removeAll()
        hasScannedOnce = false
        lastScanTime = nil
        pendingDeviceUpdates.removeAll()
        batchUpdateTimer?.invalidate()

        // Stop any ongoing scans
        if isScanning {
            stopScanning()
        }

        objectWillChange.send()
    }

    func checkBluetoothStatus() {
        guard bluetoothEnabled else { return }
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

        Haptic.success()
    }

    func confirmEnvironmentSafety(_ safety: EnvironmentSafety) {
        userEnvironmentConfirmation = safety
        objectWillChange.send()
    }

    func needsUserConfirmation() -> Bool {
        guard bluetoothEnabled else { return false }

        // If we've completed a scan (either auto or manual) but no user confirmation
        return !hasScannedOnce || (lastScanTime != nil && userEnvironmentConfirmation == nil)
    }

    func checkCurrentState() {
        objectWillChange.send()
    }

    func getSecurityScore() -> Int {
        // If bluetooth is disabled, maximum security
        guard bluetoothEnabled else { return 15 }

        // If user has confirmed environment safety, use that
        if let userConfirmation = userEnvironmentConfirmation {
            return userConfirmation.score
        }

        // If we haven't scanned yet, return neutral score but flag for attention
        guard hasScannedOnce else { return 3 }

        // Calculate base score from scan results.
        return calculateBaseScore()
    }

    func calculateBaseScore() -> Int {
        let deviceCount = nearbyDevices.count
        let suspiciousCount = nearbyDevices.filter { $0.isSuspicious }.count
        let highRiskCount = nearbyDevices.filter { $0.riskLevel == .high }.count
        let mediumRiskCount = nearbyDevices.filter { $0.riskLevel == .medium }.count

        // Base scoring logic
        if highRiskCount >= 3 { return 0 }
        if highRiskCount >= 1 && suspiciousCount >= 2 { return 1 }
        if highRiskCount >= 1 { return 3 }
        if suspiciousCount >= 3 { return 4 }
        if mediumRiskCount >= 5 { return 5 }
        if deviceCount >= 15 { return 6 }
        if deviceCount >= 10 { return 7 }
        if deviceCount >= 5 { return 8 }
        if deviceCount >= 3 { return 9 }

        return 10 // Default moderate score
    }

    var environmentalContext: String {
        if !bluetoothEnabled {
            return "Bluetooth disabled - Maximum security"
        }

        let deviceCount = nearbyDevices.count
        let highRiskCount = nearbyDevices.filter { $0.riskLevel == .high }.count
        let suspiciousCount = nearbyDevices.filter { $0.isSuspicious }.count

        if !hasScannedOnce {
            return "Tap to scan for nearby Bluetooth devices"
        }

        if deviceCount == 0 {
            return "No Bluetooth devices detected - Secure environment"
        }

        var context = "\(deviceCount) device\(deviceCount == 1 ? "" : "s") detected"

        if highRiskCount > 0 {
            context += " (\(highRiskCount) high-risk)"
        } else if suspiciousCount > 0 {
            context += " (\(suspiciousCount) suspicious)"
        }

        if let safety = userEnvironmentConfirmation {
            context += " - \(safety.description)"
        }

        return context
    }

    // MARK: - CBCentralManagerDelegate
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

        // add to pending updates for batch processing
        pendingDeviceUpdates.append(deviceInfo)

        // Start or reset batch timer
        batchUpdateTimer?.invalidate()
        batchUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            self.processPendingDeviceUpdates()
        })
    }
}
