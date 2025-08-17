//
//  ComponentConfiguration.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/15/25.
//

import Foundation
import SwiftUI

struct ComponentConfiguration {
    let name: String
    let type: ComponentType
    let icon: String
    let title: String
    let description: String
    let question: String
    let positiveText: String
    let negativeText: String
    let detailContent: AnyView?

    init(name: String, type: ComponentType, icon: String, title: String, description: String, question: String, positiveText: String, negativeText: String, detailContent: AnyView? = nil) {
        self.name = name
        self.type = type
        self.icon = icon
        self.title = title
        self.description = description
        self.question = question
        self.positiveText = positiveText
        self.negativeText = negativeText
        self.detailContent = detailContent
    }
}
