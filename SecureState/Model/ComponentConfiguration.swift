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

extension ComponentConfiguration {
    static func create(for component: SecurityComponent,
                       networkType: String? = nil,
                       networkName: String? = nil,
                       locationDetector: EnhancedLocationContextDetector? = nil) -> ComponentConfiguration {

        switch component.name {
        case "iOS Version":
            return ComponentConfiguration(
                name: "iOS Version",
                type: .contextual,
                icon: component.icon,
                title: "iOS Version Status",
                description: "Keeping iOS updated is crucial for security.",
                question: "Is your iOS version up to date?",
                positiveText: "Yes, I'm up to date",
                negativeText: "No, update available"
            )

        case "VPN Status":
            return ComponentConfiguration(
                name: "VPN Status",
                type: .contextual,
                icon: component.icon,
                title: "VPN Status",
                description: "A VPN encrypts your connection and protects your privacy.",
                question: "Are you currently using a VPN?",
                positiveText: "Yes, using VPN",
                negativeText: "No VPN active"
            )

        case "Network Security":
            return ComponentConfiguration(
                name: "Network Security",
                type: .complex,
                icon: component.icon,
                title: "Network Security",
                description: "Network security depends on who else can access your connection.",
                question: "Are you sharing this network with strangers?",
                positiveText: "No, it's private/trusted",
                negativeText: "Yes, it's shared/public"
            )

        case "Location Context":
            return ComponentConfiguration(
                name: "Location Context",
                type: .complex,
                icon: component.icon,
                title: "Location Security Context",
                description: "Your location affects your security risk profile.",
                question: "Select your current security context",
                positiveText: "",
                negativeText: ""
            )

        case "Device Lock Security":
            return ComponentConfiguration(
                name: "Device Lock Security",
                type: .complex,
                icon: component.icon,
                title: "Device Lock Security",
                description: "Your device lock is the first line of defense against physical access.",
                question: "Let's verify your device security setup",
                positiveText: "",
                negativeText: ""
            )

        case "Bluetooth Security":
            return ComponentConfiguration(
                name: "Bluetooth Security",
                type: .complex,
                icon: component.icon,
                title: "Bluetooth Environment Safety",
                description: "Assess the security risk from nearby Bluetooth devices in your current environment.",
                question: "How safe does this Bluetooth environment feel?",
                positiveText: "",
                negativeText: ""
            )

            // Add other components...
        default:
            return ComponentConfiguration(
                name: component.name,
                type: .contextual,
                icon: component.icon,
                title: component.name,
                description: "This component helps protect your device.",
                question: "Please confirm status",
                positiveText: "Yes",
                negativeText: "No"
            )
        }
    }
}
