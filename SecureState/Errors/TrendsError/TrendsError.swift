//
//  TrendsError.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation

enum TrendsError: LocalizedError {
    case missingAPIKey(String)
    case invalidResponse
    case networkError
    case invalidURL(String)
    case dateCalculationFailed
    case urlConstructionFailed(String)
    case invalidDate

    var errorDescription: String? {
        switch self {
        case .missingAPIKey(let source):
            return "Missing API key for \(source)"
        case .invalidResponse:
            return "Invalid response from security feed"
        case .networkError:
            return "Network connection failed"
        case .invalidURL(let source):
            return "Invalid URL: \(source)"
        case .dateCalculationFailed:
            return "Failed to calculate date"
        case .urlConstructionFailed(let source):
            return "Failed to construct URL: \(source)"
        case .invalidDate:
            return "Invalid date"
        }
    }
}
