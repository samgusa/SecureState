//
//  NVDCVEResponse.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI

struct NVDCVEResponse: Codable {
    let resultsPerPage: Int
    let totalResults: Int
    let vulnerabilities: [CVEItem]?

    struct CVEItem: Codable {
        let cve: CVEDetail

        struct CVEDetail: Codable {
            let id: String
            let published: String
            let descriptions: [Description]?
            let metrics: Metrics?
            let weakness: [Weakness]?
            let configurations: [Configuration]?

            struct Description: Codable {
                let lang: String
                let value: String
            }

            struct Weakness: Codable {
                let description: [WeaknessDescription]

                struct WeaknessDescription: Codable {
                    let lang: String
                    let value: String // This is like "CWE-79"
                }
            }

            struct Configuration: Codable {
                let nodes: [Node]?

                struct Node: Codable {
                    let cpeMatch: [CPEMatch]?

                    struct CPEMatch: Codable {
                        let criteria: String
                    }
                }
            }

            struct Metrics: Codable {
                let cvssMetricV31: [CVSSMetric]?
                let cvssMetricV2: [CVSSMetric]?

                struct CVSSMetric: Codable {
                    let cvssData: CVSSData

                    struct CVSSData: Codable {
                        let baseSeverity: String?
                    }
                }
            }
        }
    }
}
