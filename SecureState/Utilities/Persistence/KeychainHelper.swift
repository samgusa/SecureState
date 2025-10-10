//
//  KeychainHelper.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//

import Foundation
import SwiftData

enum KeychainHelper {
    static func save(_ data: Data, service: String, account: String) -> Bool {
        let query: [String: Any] = [ kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrService as String: service,
                                     kSecAttrAccount as String: account,
                                     kSecValueData as String: data ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    static func load(service: String, account: String) -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return item as? Data
    }
}
