//
//  EnvironmentalMetadata.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/8/25.
//

struct EnvironmentalMetadata: Codable {
    let networkTrustLevel: EnvironmentalSecurityDetector.NetworkTrustLevel?
    let environmentType: EnvironmentalSecurityDetector.EnvironmentType?

    enum CodingKeys: String, CodingKey {
        case networkTrustLevel
        case environmentType
    }

    init(networkTrustLevel: EnvironmentalSecurityDetector.NetworkTrustLevel?, environmentType: EnvironmentalSecurityDetector.EnvironmentType?) {
        self.networkTrustLevel = networkTrustLevel
        self.environmentType = environmentType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode network trust level
        if let trustString = try container.decodeIfPresent(String.self, forKey: .networkTrustLevel) {
            self.networkTrustLevel = EnvironmentalSecurityDetector.NetworkTrustLevel(rawValue: trustString)
        } else {
            self.networkTrustLevel = nil
        }
        // Decode environment type
        if let envString = try container.decodeIfPresent(String.self, forKey: .environmentType) {
            self.environmentType = EnvironmentalSecurityDetector.EnvironmentType(rawValue: envString)
        } else {
            self.environmentType = nil
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(networkTrustLevel?.rawValue, forKey: .networkTrustLevel)
        try container.encodeIfPresent(environmentType?.rawValue, forKey: .environmentType)
    }

}
