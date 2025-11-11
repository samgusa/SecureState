//
//  APIKeyManager.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Security
import Foundation

class APIKeyManager {

    // MARK: Key Identifiers
    private enum KeyIdentifier: String {
        case nvdAPIKey = "com.securestate.nvd.apikey"
    }

    // MARK: - Public Methods

    /// Store NVD API Key securely
    static func storeNVDKey(_ key: String) -> Bool {
        return storeKey(key, identifier: .nvdAPIKey)
    }

    /// Retrieve NVD API Key
    static func retrieveNVDKey() -> String? {
        return retrieveKey(identifier: .nvdAPIKey)
    }

    /// Delete NVD API Key
    static func deleteNVDKey() -> Bool {
        return deleteKey(identifier: .nvdAPIKey)
    }

    private static func storeKey(_ key: String, identifier: KeyIdentifier) -> Bool {
        guard let keyData = key.data(using: .utf8) else {
            return false
        }

        // delete existing key first
        _ = deleteKey(identifier: identifier)

        // prepare query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier.rawValue,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }

    private static func retrieveKey(identifier: KeyIdentifier) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let keyData = result as? Data,
           let key = String(data: keyData, encoding: .utf8) {
            return key
        } else if status == errSecItemNotFound {
            return nil
        } else {
            return nil
        }
    }

    private static func deleteKey(identifier: KeyIdentifier) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess || status == errSecItemNotFound
    }
}
