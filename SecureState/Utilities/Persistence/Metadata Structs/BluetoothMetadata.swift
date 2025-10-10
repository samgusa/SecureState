//
//  BluetoothMetadata.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//
import Foundation

struct BluetoothMetadata: Codable {
    let environmentSafety: EnhancedBluetoothSecurityDetector.EnvironmentSafety?

    enum CodingKeys: String, CodingKey {
        case environmentSafety
    }

    init(environmentSafety: EnhancedBluetoothSecurityDetector.EnvironmentSafety?) {
        self.environmentSafety = environmentSafety
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let safetyString = try container.decodeIfPresent(String.self, forKey: .environmentSafety)

        if let safetyString = safetyString {
            switch safetyString {
            case "safe": self.environmentSafety = .safe
            case "caution": self.environmentSafety = .caution
            case "unsafe": self.environmentSafety = .unsafe
            default: self.environmentSafety = nil
            }
        } else {
            self.environmentSafety = nil
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let safetyString: String?
        switch environmentSafety {
        case .safe: safetyString = "safe"
        case .caution: safetyString = "caution"
        case .unsafe: safetyString = "unsafe"
        case nil: safetyString = nil
        }
        try container.encodeIfPresent(safetyString, forKey: .environmentSafety)
    }
}
