//
//  DeviceLockMetadata.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//

import Foundation

struct DeviceLockMetadata: Codable {
    var sixDigitPasscode: Bool?
    var strongPasscode: Bool?
    var quickAutoLock: Bool?
    var biometricAvailable: Bool?
    var biometricTestPassed: Bool?
}
