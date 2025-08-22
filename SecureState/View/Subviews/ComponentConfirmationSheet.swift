//
//  ComponentConfirmationSheet.swift
//  SecureState
//
//  Created by Sam Greenhill on 7/6/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct ComponentConfirmationSheet: View {
    let component: SecurityComponent
    let config: ComponentConfiguration
    let onConfirm: (Bool) -> Void
    let onDismiss: () -> Void

    // Location-specific properties
    let locationDetector: EnhancedLocationContextDetector?
    let networkType: String?
    let networkName: String?

    @State private var showPreciseLocation = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var hideLocationTimer: Timer?

    /// DONE
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with icon and title
                    headerSection

                    // Dynamic content based on component type
                    switch config.type {
                    case .simple:
                        simpleConfirmationContent
                    case .contextual:
                        contextualConfirmationContent
                    case .complex:
                        complexConfirmationContent
                    }

                    Spacer(minLength: 24)

                    // Action buttons
                    actionButtons
                }
                .padding()
            }
            .navigationTitle(config.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") { onDismiss() }
            )
        }
        .presentationDetents([config.type.presentationDetent])
        .presentationDragIndicator(.visible)
        .onAppear {
            setupForComponentType()
        }
    }

    // MARK: - Header Section
    /// DONE
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(component.status.color.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: config.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(component.status.color)
            }

            VStack(spacing: 8) {
                Text(config.title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(config.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Simple Confirmation Content
    /// DONE
    private var simpleConfirmationContent: some View {
        VStack(spacing: 16) {
            Text(config.question)
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)

            if let networkContext = getNetworkContext() {
                contextCard(networkContext)
            }
        }
    }

    // MARK: - Contextual Confirmation Content
    private var contextualConfirmationContent: some View {
        VStack(spacing: 20) {
            Text(config.question)
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)

            // Network Security specific content
            if config.name == "Network Security" {
                networkSecurityContextView
            }

            // Add other contextual components here as needed
        }
    }

    // MARK: - Complex Confirmation Content
    /// DONE
    private var complexConfirmationContent: some View {
        VStack(spacing: 20) {
            if config.name == "Location Context" {
                locationContextView
            } else {
                // Fallback to contextual content
                contextualConfirmationContent
            }
        }
    }

    // MARK: - Network Security Context
    // DONE
    private var networkSecurityContextView: some View {
        VStack(spacing: 16) {
            Text(config.question)
                .font(.headline)
                .fontWeight(.medium)

            VStack(spacing: 12) {
                networkTypeCard("Private Networks",
                               "Home, work, or networks you control",
                               "house.fill", .green)

                networkTypeCard("Public Networks",
                               "Coffee shops, airports, hotels",
                               "wifi", .orange)

                networkTypeCard("Cellular Connection",
                               "Private connection through your carrier",
                               "antenna.radiowaves.left.and.right", .blue)
            }

            infoBox("Shared networks allow others to potentially intercept traffic or discover your device.")
        }
    }

    // MARK: - Location Context View
    // DONE
    private var locationContextView: some View {
        VStack(spacing: 20) {
            if let detector = locationDetector {
                LocationDetectionStatusView(detector: detector)

                if let snapshot = detector.currentLocationSnapshot {
                    LocationMapView(
                        snapshot: snapshot,
                        showPreciseLocation: $showPreciseLocation,
                        mapRegion: $mapRegion,
                        hideLocationTimer: $hideLocationTimer
                    )
                }

                LocationContextSelectionView(
                    detector: detector,
                    onSelection: { context in
                        // Handle location context selection
                        NotificationCenter.default.post(
                            name: .locationContextSelected,
                            object: context
                        )

                        onConfirm(true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onDismiss()
                        }
                    }
                )
            } else {
                Text("Location detector not available")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Action Buttons
    /// DONE
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Only show standard Yes/No buttons for simple and contextual types
            if config.type != .complex {
                Button(config.positiveText) {
                    onConfirm(true)
                    onDismiss()
                }
                .buttonStyle(PrimaryButtonStyle())

                Button(config.negativeText) {
                    onConfirm(false)
                    onDismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
    }

    // MARK: - Helper Views
    /// DONE
    private func contextCard(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }

    /// DONE
    private func networkTypeCard(_ title: String, _ description: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    /// DONE
    private func infoBox(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.blue)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Helper Methods
    /// DONE
    private func getNetworkContext() -> String? {
        switch config.name {
        case "VPN Status":
            return "Check Settings > VPN & Device Management > VPN for third-party VPNs, or Settings > Privacy & Security > iCloud Private Relay for Apple's service."
        case "Network Type":
            if let networkType = networkType {
                return "Currently connected to: \(networkType)"
            }
            return nil
        default:
            return nil
        }
    }

    /// DONE
    private func setupForComponentType() {
        if config.name == "Location Context", let detector = locationDetector,
           let snapshot = detector.currentLocationSnapshot {
            mapRegion = MKCoordinateRegion(
                center: snapshot.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}

#Preview {
    ComponentConfirmationSheet(component:
                                SecurityComponent(
                                    name: "Test",
                                    score: 15,
                                    maxScore: 20,
                                    icon: "shield"
                                ),
                               config: ComponentConfiguration(
                                name: "iOS Version",
                                type: .simple,
                                icon: "wifi",
                                title: "iOS Version Status",
                                description: "Keeping iOS updated is crucial for security.",
                                question: "Is your iOS version up to date?",
                                positiveText: "Yes, I'm up to date",
                                negativeText: "No, update available"
                               ),
                               onConfirm: { _ in

    },
                               onDismiss: {

    },
                               locationDetector: nil,
                               networkType: "Testing",
                               networkName: ""
    )
}

