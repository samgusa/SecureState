//
//  DeviceLockSecurityDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import Foundation
import LocalAuthentication

class DeviceLockSecurityDetector: ObservableObject {
    @Published var biometricAvailable: Bool = false
    @Published var biometricEnrolled: Bool = false
    @Published var passcodeSet: Bool = false
    @Published var biometricType: LABiometryType = .none
    @Published var lastBiometricTest: Date? = nil
    @Published var biometricTestPassed: Bool = false

    // User confirmation states
    @Published var userConfirmedSixDigitPasscode: Bool? = nil
    @Published var userConfirmedStrongPasscode: Bool? = nil
    @Published var userConfirmedQuickAutoLock: Bool? = nil
    @Published var detectionConfidence: ConfidenceLevel = .medium
    @Published var isTestingBiometric: Bool = false

    private let maxScore: Int = 10
    private let context = LAContext()

    init() {
        checkDeviceLockCapabilities()
    }

    func checkDeviceLockCapabilities() {
        var error: NSError?

        // check if biometrics are available and enrolled
        biometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        biometricEnrolled = biometricAvailable && error == nil

        // check if passcode is set
        passcodeSet = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)

        // get biometric type
        biometricType = context.biometryType

        // set detection confidence
        detectionConfidence = (biometricAvailable && passcodeSet) ? .high : .medium
    }

    func performBiometricTest() async -> Bool {
        guard biometricAvailable else { return false }

        await MainActor.run {
            isTestingBiometric = true
        }

        let context = LAContext()
        context.localizedReason = "Test your biometric authenticationto verify it's working"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Verify your biometri authentication is working"
            )
            await MainActor.run {
                biometricTestPassed = success
                lastBiometricTest = success ? Date() : nil
                isTestingBiometric = false
            }
            return success
        } catch {
            await MainActor.run {
                biometricTestPassed = false
                lastBiometricTest = nil
                isTestingBiometric = false
            }
            return false
        }
    }

    func getSecurityScore() -> Int {
        let hasBiometrics = biometricAvailable && biometricTestPassed
        let hasSixDigitPasscode = userConfirmedSixDigitPasscode == true
        let hasStrongPasscode = userConfirmedStrongPasscode == true
        let hasQuickAutoLock = userConfirmedQuickAutoLock == true

        // scoring logic as specified
        if hasBiometrics && hasSixDigitPasscode && hasStrongPasscode && hasQuickAutoLock {
            return 15 // perfect setup
        } else if hasBiometrics && hasSixDigitPasscode && hasStrongPasscode {
            return 12 // very good
        } else if hasBiometrics && (hasSixDigitPasscode || hasStrongPasscode) {
            return 10 // good biometrics with decent passcode
        } else if hasSixDigitPasscode && hasStrongPasscode && hasQuickAutoLock {
            return 7 // strong passcode but no biometrics
        } else if passcodeSet && (hasStrongPasscode || hasStrongPasscode) {
            return 4 // Basic but decent setup
        } else if passcodeSet {
            return 2
        } else {
            return 0
        }
    }

    func confirmSixDigitPasscode(_ confirmed: Bool) {
        userConfirmedSixDigitPasscode = confirmed
    }

    func confirmStrongPasscode(_ confirmed: Bool) {
        userConfirmedStrongPasscode = confirmed
    }

    func confirmQuickAutoLock(_ confirmed: Bool) {
        userConfirmedQuickAutoLock = confirmed
    }

    func needsUserConfirmation() -> Bool {
        return userConfirmedSixDigitPasscode == nil ||
        userConfirmedStrongPasscode == nil ||
        userConfirmedQuickAutoLock == nil ||
        (biometricAvailable && !biometricTestPassed)
    }

    var biometricTypeString: String {
        switch biometricType {
        case .none: return "None"
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        case .opticID: return "Optic ID"
        @unknown default: return "Biometric Authenticator"
        }
    }

    var statusDescription: String {
        let biometricStatus = biometricAvailable ? "\(biometricTypeString) available" : "No biometrics"
        let passcodeStatus = passcodeSet ? "Passcode set" : "No passcode"
        let testStatus = biometricTestPassed ? "✓ Tested" : ""
        return "\(biometricStatus), \(passcodeStatus) \(testStatus)".trimmingCharacters(in: .whitespaces)
    }

    var scoreExplanation: String {
        let score = getSecurityScore()
        if score >= 9 {
            return "Excellent device security (\(score)/\(maxScore))"
        } else if score >= 7 {
            return "Good security with biometrics (\(score)/\(maxScore))"
        } else if score >= 6 {
            return "Decent passcode security (\(score)/\(maxScore))"
        } else if score >= 2 {
            return "Basic security setup (\(score)/\(maxScore))"
        } else {
            return "Weak device security (\(score)/\(maxScore))"
        }
    }

}
