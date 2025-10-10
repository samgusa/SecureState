//
//  Extensions+String.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//

import Foundation
import Security
import CryptoKit

extension String {
    func sha256Hex() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
