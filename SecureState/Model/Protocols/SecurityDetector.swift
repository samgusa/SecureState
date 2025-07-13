//
//  SecurityDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 7/12/25.
//

import Foundation

protocol SecurityDetector: ObservableObject {
    var detectorName: String { get }
    func getSecurityScore() -> Int
    func getMaxScore() -> Int
    func needsUserConfirmation() -> Bool
    func checkCurrentState()
}
