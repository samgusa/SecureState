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
                       locationDetector: EnhancedLocationContextDetector? = nil,
                       environmentalDetector: EnvironmentalSecurityDetector? = nil) -> ComponentConfiguration {

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

    var educationalContent: ComponentEducationContent {
        switch name {
        case "iOS Version":
            return ComponentEducationContent(
                explanation: "Keeping iOS updated is crucial for security because Apple regularly patches vulnerabilities that attackers could exploit to compromise your device.",
                howToCheck: "Settings > General > Software Update",
                whyItMatters: "Each iOS update includes security patches that fix known vulnerabilities. Running an outdated version leaves your device exposed to attacks.",
                improvementSteps: [
                    "Go to Settings > General > Software Update",
                    "Download and install any available updates",
                    "Enable automatic updates: Settings > General > Software Update > Automatic Updates"
                ],
                riskScenarios: [
                    "Banking apps may be vulnerable to interception on older iOS versions",
                    "Password managers could be compromised through known exploits",
                    "Personal data could be accessed through unpatched security holes"
                ]
            )
        case "VPN Status":
            return ComponentEducationContent(
                explanation: "A VPN (Virtual Private Network) encrypts your internet traffic and routes it through secure servers, protecting your data from being intercepted.",
                howToCheck: "Settings > VPN & Device Management > VPN, or Settings > Privacy & Security > iCloud Private Relay",
                whyItMatters: "Without a VPN, your internet traffic can be monitored by others on the same network, especially on public Wi-Fi.",
                improvementSteps: [
                    "Choose a reputable VPN service (NordVPN, ExpressVPN, etc.)",
                    "Download the VPN app and follow setup instructions",
                    "Or enable iCloud Private Relay: Settings > [Your Name] > iCloud > Private Relay"
                ],
                riskScenarios: [
                    "On public Wi-Fi, others could see what websites you visit",
                    "Your internet provider could monitor your browsing habits",
                    "Attackers could intercept sensitive data like passwords"
                ]
            )

        case "Screen Recording":
            return ComponentEducationContent(
                explanation: "Screen recording detection alerts you when your screen content is being captured, which could compromise sensitive information.",
                howToCheck: "Look for recording indicators in Control Center or check if any apps have screen recording permission",
                whyItMatters: "Screen recording can capture passwords, banking information, private messages, and other sensitive data without your knowledge.",
                improvementSteps: [
                    "Stop any active screen recordings",
                    "Check Control Center for recording indicators",
                    "Review app permissions: Settings > Privacy & Security > Screen & System Audio Recording"
                ],
                riskScenarios: [
                    "Malicious apps could record your banking sessions",
                    "Screen sharing software might capture sensitive information",
                    "Your passwords could be visible in recorded content"
                ]
            )

        case "Environmental Security":
            return ComponentEducationContent(
                explanation: """
                Environmental security combines your physical location safety with network connection security to give you a complete risk assessment. 
                
                Your environment affects both digital risks (who can see your network traffic) and physical risks (who can observe your screen or access your device). A coffee shop with public Wi-Fi presents different combined risks than your home with the same public Wi-Fi hotspot from your phone.
                
                The scoring system rewards secure combinations: private locations + trusted networks score highest, while public spaces + shared networks score lowest.
                """,

                howToCheck: """
                Network Security:
                • Cellular: Check signal strength in Control Center
                • Wi-Fi: Settings > Wi-Fi to see current network
                • VPN: Settings > VPN & Device Management or Privacy & Security > Private Relay
                
                Physical Environment:
                • Look around for other people who might observe your screen
                • Consider who else has access to your current Wi-Fi network
                • Assess whether you're in a controlled vs public space
                """,

                whyItMatters: """
                Environmental security prevents multiple attack vectors simultaneously:
                
                Network Risks: Shared Wi-Fi allows others to potentially monitor your traffic, discover your device, or attempt malicious connections. Public networks may be run by attackers.
                
                Physical Risks: Public spaces allow screen observation, device theft, and social engineering. Someone watching you enter passwords poses immediate risk.
                
                Combined Risks: A public space with public Wi-Fi maximizes exposure to both digital and physical attacks simultaneously.
                """,

                improvementSteps: [
                    "Use cellular data in public spaces - it's a private encrypted tunnel through your carrier",
                    "Find a private location for sensitive activities like banking or password management",
                    "On shared Wi-Fi, enable VPN or iCloud Private Relay to encrypt your traffic",
                    "Position your screen away from others when in public spaces",
                    "Avoid financial activities entirely in high-risk environments (airports, coffee shops)",
                    "At home, ensure your Wi-Fi has WPA3 security and a strong password",
                    "Create a 'trusted networks' mental list: home, work, family - confirm others as public"
                ],

                riskScenarios: [
                    "Coffee shop with public Wi-Fi: Others can monitor your network traffic AND observe your screen - worst case for banking or passwords",
                    "Airport terminal: High device theft risk, untrusted Wi-Fi, many observers - avoid any sensitive activities",
                    "Home with neighbor's Wi-Fi: Network may be monitored by neighbor, but physical environment is safe - mixed risk",
                    "Work with company Wi-Fi: IT can see traffic but physical space is trusted - good for most activities",
                    "Car with phone hotspot: Cellular network is secure and space is private - excellent for sensitive activities",
                    "Hotel Wi-Fi in room: Network is shared but physical space is private - moderate risk, use VPN"
                ]
            )

        case "Device Lock Security":
            return ComponentEducationContent(
                explanation: "Your device lock is the first line of defense against physical access to your personal information if your device is lost, stolen, or accessed by others.",
                howToCheck: "Settings > Face ID & Passcode (or Touch ID & Passcode) and Settings > Display & Brightness > Auto-Lock",
                whyItMatters: "A weak or missing device lock allows anyone with physical access to your device to read messages, access accounts, and steal personal information.",
                improvementSteps: [
                    "Set up Face ID or Touch ID: Settings > Face ID & Passcode",
                    "Use a 6-digit passcode (not 4): Settings > Face ID & Passcode > Change Passcode > Passcode Options",
                    "Choose a strong, non-obvious passcode (avoid 123456, 000000, birthdates)",
                    "Set auto-lock to 2-5 minutes: Settings > Display & Brightness > Auto-Lock"
                ],
                riskScenarios: [
                    "Anyone finding your device could access banking apps",
                    "Personal messages and photos could be viewed",
                    "Stored passwords and payment methods could be compromised"
                ]
            )

        case "Bluetooth Security":
            return ComponentEducationContent(
                explanation: "Bluetooth devices in your environment can indicate the security risk level of your current location and potential exposure to Bluetooth-based attacks.",
                howToCheck: "Settings > Bluetooth shows paired devices, but many devices broadcast without being paired",
                whyItMatters: "In public spaces with many unknown Bluetooth devices, there's increased risk of tracking, proximity attacks, or malicious connection attempts.",
                improvementSteps: [
                    "Turn off Bluetooth when not needed: Settings > Bluetooth",
                    "Remove old or unknown paired devices",
                    "Be cautious about accepting new Bluetooth connections",
                    "Use cellular data instead of public Wi-Fi in crowded areas"
                ],
                riskScenarios: [
                    "Malicious actors could attempt to connect to your device",
                    "Bluetooth tracking could compromise your privacy",
                    "Crowded environments indicate higher overall security risk"
                ]
            )

        case "Time-based Risk":
            return ComponentEducationContent(
                explanation: "Security risks increase during late night or early morning hours when fatigue can impair judgment and response to security threats.",
                howToCheck: "Consider your current alertness level and the time of day",
                whyItMatters: "Fatigue reduces your ability to notice security threats, make good decisions, and respond appropriately to suspicious activity.",
                improvementSteps: [
                    "Avoid important financial tasks when tired",
                    "Be extra cautious with password entry during late hours",
                    "Consider waiting until you're more alert for sensitive activities",
                    "Use additional verification for important actions when tired"
                ],
                riskScenarios: [
                    "You might not notice suspicious activity when tired",
                    "Poor judgment could lead to clicking malicious links",
                    "Fatigue might cause you to ignore security warnings"
                ]
            )

        default:
            return ComponentEducationContent(
                explanation: "This component helps protect your device and data.",
                howToCheck: "Check your device settings for related security options.",
                whyItMatters: "Each security component contributes to your overall protection.",
                improvementSteps: ["Review your security settings regularly"],
                riskScenarios: ["Weak security can expose your personal information"]
            )
        }
    }
}
