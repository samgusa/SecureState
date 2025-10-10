//
//  CryptoManager.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//

import Foundation
import SwiftData
import Security
import CryptoKit

struct CryptoManager {
    private static let keyService = "com.simplyamazingmachines.SecureState.crypto"
    private static let keyAccount = "symmetricKey"

    static func getKey() -> SymmetricKey {
        if let data = KeychainHelper.load(service: keyService, account: keyAccount) {
            return SymmetricKey(data: data)
        }
        let key = SymmetricKey(size: .bits256)
        let data = key.withUnsafeBytes { Data(Array($0)) }
        _ = KeychainHelper.save(data, service: keyService, account: keyAccount)
        return key
    }
}
