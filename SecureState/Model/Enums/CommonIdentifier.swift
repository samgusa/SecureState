//
//  CommonIdentifier.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import Foundation

enum ComponentIdentifier: String, CaseIterable {
    case screenRecording = "Screen Recording Detection"
    case iosVersion = "iOS Version"
    case vpnStatus = "VPN Status"
    case deviceLock = "Device Lock Security"
    case environmentalSecurity = "Environmental Security"
    case timeBasedRisk = "Time-based Risk"
    case bluetoothSecurity = "Bluetooth Security"

    var displayName: String {
        return self.rawValue
    }

    var isDeviceComponent: Bool {
        switch self {
        case .screenRecording, .iosVersion, .vpnStatus, .deviceLock:
            return true
        case .environmentalSecurity, .timeBasedRisk, .bluetoothSecurity:
            return false
        }
    }
}
