//
//  BluetoothDeviceInfo.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/10/25.
//

import Foundation
import CoreBluetooth
import SwiftUI

struct BluetoothDeviceInfo: Identifiable, Hashable {
    var id = UUID()
    let peripheral: CBPeripheral
    let rssi: Int
    let advertisementData: [String: Any]
    let discoveredAt: Date

    // MARK: Cached properties (computed once, stored)
    private let _cachedName: String
    private let _cachedIsGeneric: Bool
    private let _cachedIsSuspicious: Bool
    private let _cachedDeviceCategory: DeviceCategory
    private let _cachedEstimatedDistance: DistanceRange
    private let _cachedRiskLevel: RiskLevel
    private let _cachedSignalStrengthDescription: String
    private let _cachedSignalStrengthIcon: String
    private let _cachedIsActiveScanning: Bool

    // MARK: - Initializer with caching
    init(peripheral: CBPeripheral, rssi: Int, advertisementData: [String: Any], discoveredAt: Date) {
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertisementData = advertisementData
        self.discoveredAt = discoveredAt
        
        self._cachedName = Self.computeName(for: peripheral)
        self._cachedIsGeneric = Self.computeIsGeneric(_cachedName)
        self._cachedIsSuspicious = Self.computeIsSuspicious(name: _cachedName)
        self._cachedDeviceCategory = Self.computeDeviceCategory(
            name: _cachedName,
            isGeneric: _cachedIsGeneric,
            isSuspicious: _cachedIsSuspicious
        )
        self._cachedEstimatedDistance = Self.computeEstimatedDistance(rssi: rssi)
        self._cachedSignalStrengthDescription = Self.computeSignalStrengthDescription(rssi: rssi)
        self._cachedSignalStrengthIcon = Self.computeSignalStrengthIcon(rssi: rssi)
        self._cachedIsActiveScanning = Self.computeIsActiveScanning(advertisementData: advertisementData)
        self._cachedRiskLevel = Self.computeRiskLevel(
            isSuspicious: _cachedIsSuspicious,
            isGeneric: _cachedIsGeneric,
            estimatedDistance: _cachedEstimatedDistance,
            deviceCategory: _cachedDeviceCategory,
            isActiveScanning: _cachedIsActiveScanning
        )
    }

    var name: String { _cachedName }
    var isGeneric: Bool { _cachedIsGeneric }
    var isSuspicious: Bool { _cachedIsSuspicious }
    var deviceCategory: DeviceCategory { _cachedDeviceCategory }
    var estimatedDistance: DistanceRange { _cachedEstimatedDistance }
    var riskLevel: RiskLevel { _cachedRiskLevel }
    var signalStengthDescription: String { _cachedSignalStrengthDescription }
    var signalStrengthIcon: String { _cachedSignalStrengthIcon }
    var isActiveScanning: Bool { _cachedIsActiveScanning }

    // MARK: - Static Computation methods (called once per device)
    private static func computeName(for peripheral: CBPeripheral) -> String {
        return peripheral.name ?? "Unknown Device"
    }

    private static func computeIsGeneric(_ name: String) -> Bool {
        let genericPatterns = [
            "Unknown", "Device", "BLE", "Bluetooth",
            "Generic", "Accessory", "Peripheral"
        ]
        let lowercaseName = name.lowercased()
        return genericPatterns.contains { lowercaseName.contains($0.lowercased()) }
    }

    private static func computeIsSuspicious(name: String) -> Bool {
        let suspiciousPatterns = [
            "hack", "spy", "monitor", "sniffer", "capture",
            "test", "debug", "dev", "scanner"
        ]
        let lowercaseName = name.lowercased()
        return suspiciousPatterns.contains { lowercaseName.contains($0) } ||
        name.isEmpty ||
        name.count < 3 ||
        name.allSatisfy { $0.isNumber || $0.isPunctuation }
    }

    private static func computeDeviceCategory(name: String, isGeneric: Bool, isSuspicious: Bool) -> DeviceCategory {
        if isSuspicious { return .suspicious }
        if isGeneric { return .generic }

        let lowercaseName = name.lowercased()

        if lowercaseName.contains("airpods") || lowercaseName.contains("beats") { return .audio }
        if lowercaseName.contains("watch") || lowercaseName.contains("fitness") { return .wearable }
        if lowercaseName.contains("phone") || lowercaseName.contains("iphone") { return .phone }
        if lowercaseName.contains("car") || lowercaseName.contains("auto") { return .vehicle }
        if lowercaseName.contains("speaker") || lowercaseName.contains("sound") { return .audio }
        if lowercaseName.contains("keyboard") || lowercaseName.contains("mouse") { return .input }

        return .unknown
    }

    private static func computeEstimatedDistance(rssi: Int) -> DistanceRange {
        switch rssi {
        case -30...0: return .immediate // 0-1m
        case -60..<(-30): return .near // 1-5m
        case -80..<(-60): return .medium // 5-15m
        default: return .far
        }
    }

    private static func computeSignalStrengthDescription(rssi: Int) -> String {
        switch rssi {
        case -30...0: return "Very Strong"
        case -50..<(-30): return "Strong"
        case -70..<(-50): return "Moderate"
        case -90..<(-70): return "Weak"
        default: return "Very Weak"
        }
    }

    private static func computeSignalStrengthIcon(rssi: Int) -> String {
        switch rssi {
        case -30...0: return "wifi"
        case -50..<(-30): return "wifi"
        case -70..<(-50): return "wifi"
        case -90..<(-70): return "wifi.slash"
        default: return "wifi.exclamationmark"
        }
    }

    private static func computeIsActiveScanning(advertisementData: [String: Any]) -> Bool {
        return advertisementData[CBAdvertisementDataIsConnectable] as? Bool == true
    }

    private static func computeRiskLevel(
        isSuspicious: Bool,
        isGeneric: Bool,
        estimatedDistance: DistanceRange,
        deviceCategory: DeviceCategory,
        isActiveScanning: Bool
    ) -> RiskLevel {
        if isSuspicious { return .high }
        if isGeneric && estimatedDistance == .immediate { return .medium }
        if isActiveScanning && deviceCategory == .unknown { return .medium }
        return .low
    }


    enum DeviceCategory {
        case audio, wearable, phone, vehicle, input, generic, unknown, suspicious

        var icon: String {
            switch self {
            case .audio: return "headphones"
            case .wearable: return "applewatch"
            case .phone: return "iphone"
            case .vehicle: return "car.fill"
            case .input: return "keyboard"
            case .generic: return "dot.radiowaves.left.and.right"
            case .unknown: return "questionmark.circle"
            case .suspicious: return "exclamationmark.triangle.fill"
            }
        }

        var color: Color {
            switch self {
            case .audio, .wearable, .phone, .input: return .blue
            case .vehicle: return .green
            case .generic: return .gray
            case .unknown: return .orange
            case .suspicious: return .red
            }
        }
    }

    enum DistanceRange {
        case immediate, near, medium, far

        var description: String {
            switch self {
            case .immediate: return "Very Close (0-1m)"
            case .near: return "Near (1-5m)"
            case .medium: return "Medium (5-15m)"
            case .far: return "Far (15+)"
            }
        }

        var icon: String {
            switch self {
            case .immediate: return "dot.radiowaves.up.forward"
            case .near: return "dot.radiowaves.left.and.right"
            case .medium: return "dot.radiowaves.forward"
            case .far: return "antenna.radiowaves.left.and.right"
            }
        }
    }

    enum RiskLevel {
        case low, medium, high

        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }

        var description: String {
            switch self {
            case .low: return "Low Risk"
            case .medium: return "Medium Risk"
            case .high: return "High Risk"
            }
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(peripheral.identifier)
    }

    static func == (lhs: BluetoothDeviceInfo, rhs: BluetoothDeviceInfo) -> Bool {
        lhs.peripheral.identifier == rhs.peripheral.identifier
    }
}
