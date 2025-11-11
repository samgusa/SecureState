//
//  ComponentConfiguration.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/15/25.
//

import Foundation
import SwiftUI

struct ComponentConfiguration {
    let identifier: ComponentIdentifier
    let name: String
    let icon: String
    let title: String
    let description: String
    let question: String
    let positiveText: String
    let negativeText: String
    let detailContent: AnyView?

    init(identifier: ComponentIdentifier, icon: String, title: String, description: String, question: String, positiveText: String, negativeText: String, detailContent: AnyView? = nil) {
        self.identifier = identifier
        self.name = identifier.displayName
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
                      networkName: String? = nil,
                       environmentalDetector: EnvironmentalSecurityDetector? = nil) -> ComponentConfiguration {

        switch component.identifier {
        case .environmentalSecurity:
            return ComponentConfiguration(
                identifier: .environmentalSecurity,
                icon: component.icon,
                title: "Environmental Security Assessment",
                description: "Assesses your overall exposure risk from both physical environment and network connection.",
                question: "Let's evaluate your current environmental security",
                positiveText: "",
                negativeText: ""
            )

        case .iosVersion:
            return ComponentConfiguration(
                identifier: .iosVersion,
                icon: component.icon,
                title: "iOS Version",
                description: "Track how current your iOS version is and understand security implications over time.",
                question: "Check your iOS version currency",
                positiveText: "Up to Date",
                negativeText: "Update Available"
            )

        case .vpnStatus:
            return ComponentConfiguration(
                identifier: .vpnStatus,
                icon: component.icon,
                title: "VPN Traffic Protection",
                description: "See how VPNs protect your data by encrypting traffic between your device and servers.",
                question: "Experience the difference VPN makes for your security",
                positiveText: "VPN Active",
                negativeText: "No VPN"
            )

        case .deviceLock:
            return  ComponentConfiguration(
                identifier: .deviceLock,
                icon: component.icon,
                title: "Device Lock Security",
                description: "Your device lock is the first line of defense against physical access.",
                question: "Let's verify your device security setup",
                positiveText: "",
                negativeText: ""
            )

        case .screenRecording:
            return ComponentConfiguration(
                identifier: .screenRecording,
                icon: component.icon,
                title: "Screen Recording Protection",
                description: "Real-time detection of screen recording to prevent sensitive data exposure.",
                question: "Test and understand screen recording detection",
                positiveText: "",
                negativeText: ""
            )

        case .bluetoothSecurity:
            return ComponentConfiguration(
                identifier: .bluetoothSecurity,
                icon: component.icon,
                title: "Bluetooth Environment Safety",
                description: "Assess the security risk from nearby Bluetooth devices in your current environment.",
                question: "How safe does this Bluetooth environment feel?",
                positiveText: "",
                negativeText: ""
            )

        case .timeBasedRisk:
            return ComponentConfiguration(
                identifier: .timeBasedRisk,
                icon: component.icon,
                title: component.name,
                description: "",
                question: "",
                positiveText: "",
                negativeText: ""
            )
        }
    }

    var educationalContent: ComponentEducationContent {
        switch identifier {
        case .iosVersion:
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

        case .vpnStatus:
            return ComponentEducationContent(
                explanation: "A VPN (Virtual Private Network) creates an encrypted tunnel between your device and the internet. This protects your browsing activity and sensitive data from being intercepted by others on the same network, your internet provider, or malicious actors.",
                howToCheck: """
                        • Open Settings > General > VPN & Device Management > VPN to see if a VPN service is installed and active.
                        • For Apple’s built-in option, check Settings > [Your Name] > iCloud > Private Relay.
                        """,
                whyItMatters: "Without VPN protection, your internet traffic can be monitored on public Wi-Fi, logged by internet providers, or intercepted by attackers. A VPN adds a strong layer of privacy and security.",
                improvementSteps: [
                    "Choose a reputable VPN provider (e.g., NordVPN, ExpressVPN, ProtonVPN, Surfshark).",
                    "Install the VPN app from the App Store and sign in.",
                    "Enable the VPN in Settings > General > VPN & Device Management.",
                    "If you prefer Apple’s solution, turn on iCloud Private Relay in Settings > [Your Name] > iCloud.",
                    "Always connect to a VPN before using public Wi-Fi.",
                    "Verify the VPN is active by checking your IP address online."
                ],
                riskScenarios: [
                    "Using public Wi-Fi at airports, hotels, or coffee shops without a VPN leaves your traffic exposed.",
                    "Internet providers may track and log your browsing activity.",
                    "Hackers on shared networks can intercept unencrypted data (like logins or financial info).",
                    "Governments, corporations, or schools could monitor your online activity.",
                    "Your approximate location may be revealed through your IP address if no VPN or Private Relay is active."
                ]
            )

        case .screenRecording:
            return ComponentEducationContent(
                explanation: "Screen recording detection alerts you when your screen content is being captured. iOS allows screen recording as a system feature - apps can detect it but cannot prevent it.",
                howToCheck: "Look for the recording indicator in Control Center, or check the orange dot/recording indicator at the top of your screen",
                whyItMatters: "Screen recording can capture passwords, banking information, private messages, and other sensitive data. Being aware when recording is active helps you avoid exposing sensitive information.",
                improvementSteps: [
                    "Stop any active screen recordings before handling sensitive data",
                    "Check Control Center for the recording indicator (circle with dot)",
                    "Look for the orange recording indicator at the top of your screen",
                    "Be cautious about which apps you grant screen recording permission to"
                ],
                riskScenarios: [
                    "Malicious apps could record your banking sessions",
                    "Screen sharing software might inadvertently capture sensitive information",
                    "Your passwords could be visible in recorded content",
                    "Private conversations could be captured without your awareness"
                ]
            )

        case .environmentalSecurity:
            return ComponentEducationContent(
                explanation: """
                Environmental security combines your physical location safety with network connection security to give you a complete risk assessment. 
                
                Your environment affects both digital risks (who can see your network traffic) and physical risks (who can observe your screen or access your device). A coffee shop with public Wi-Fi presents different combined risks than your home with the same public Wi-Fi hotspot from your phone.
                
                The scoring system rewards secure combinations: private locations + trusted networks score highest, while public spaces + shared networks score lowest.
                """,

                // DONE
                howToCheck: """
                Network Security:
                • Cellular: Check signal strength in Control Center
                • Wi-Fi: Settings > Wi-Fi to see current network
                • VPN: Settings > General > VPN & Device Management > VPN > 
                
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

        case .deviceLock:
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
        case .bluetoothSecurity:
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
        case .timeBasedRisk:
            return ComponentEducationContent(
                explanation: "Your cognitive alertness varies throughout the day, affecting your ability to recognize security threats and make good security decisions. Fatigue impairs judgment and reaction time to suspicious activity.",
                howToCheck: "Consider your current alertness level and the time of day. Notice if you feel tired or mentally foggy.",
                whyItMatters: "Security threats often exploit human error. When you're tired, you're more likely to click suspicious links, ignore security warnings, or make poor password choices.",
                improvementSteps: [
                    "Schedule important financial activities during peak alertness hours (8am-10pm)",
                    "Be extra cautious with security decisions when tired",
                    "Set up additional verification for late-night transactions",
                    "Avoid clicking links in emails during low-alertness hours",
                    "Consider waiting until morning for important account changes"
                ],
                riskScenarios: [
                    "Late-night phishing emails are more likely to succeed",
                    "Tired users may not notice suspicious website URLs",
                    "Poor password choices when creating accounts while fatigued",
                    "Ignoring browser security warnings due to reduced attention",
                    "Social engineering attacks exploit decision fatigue"
                ]
            )
        }
    }
}
