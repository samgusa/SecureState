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
    let networkName: String?
    let deviceLockDetector: DeviceLockSecurityDetector?
    let bluetoothDetector: EnhancedBluetoothSecurityDetector?
    let environmentDetector: EnvironmentalSecurityDetector?

    @State private var showPreciseLocation = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var hideLocationTimer: Timer?

    @State private var selectedMode: DetailMode = .assessment

    enum DetailMode: String, CaseIterable {
        case assessment = "Assessment"
        case education = "Learn More"

        var icon: String {
            switch self {
            case .assessment: return "checkmark.shield.fill"
            case .education: return "graduationcap.fill"
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with icon and title
                    headerSection

                    modeSelector

                    switch selectedMode {
                    case .assessment:
                        assessmentContent
                    case .education:
                        educationalContent
                    }

                    Spacer(minLength: 20)

                    if selectedMode == .assessment && config.type != .complex {
                        // Action buttons
                        actionButtons
                    }
                }
                .padding()
            }
            .navigationTitle(config.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") { onDismiss() }
            )
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Header Section
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

                HStack(spacing: 16) {
                    // Current Score
                    VStack(spacing: 4) {
                        Text("\(component.score)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(component.status.color)

                        Text("Current Score")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text("/")
                        .font(.title)
                        .foregroundStyle(.secondary)

                    // Max Score
                    VStack(spacing: 4) {
                        Text("\(component.maxScore)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)

                        Text("Maximum")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // percentage and status
                let percentage = Double(component.score) / Double(component.maxScore)
                ProgressView(value: percentage)
                    .tint(component.status.color)
                    .scaleEffect(y: 2)

                Text("\(Int(percentage * 100))% - \(component.status == .good ? "Good" : component.status == .warning ? "Needs Attention" : "Critical")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(component.status.color)
            }
        }
    }

    private var modeSelector: some View {
        HStack(spacing: 0) {
            ForEach(DetailMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedMode = mode
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 12, weight: .medium))

                        Text(mode.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(selectedMode == mode ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedMode == mode ? Color.blue : Color.clear
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        }
    }

    @ViewBuilder
    private var assessmentContent: some View {
        VStack(spacing: 20) {
            Text(config.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            switch config.type {
            case .simple: simpleConfirmationContent
            case .contextual: contextualConfirmationContent
            case .complex: complexConfirmationContent
            }
        }
    }

    private var educationalContent: some View {
        let educational = config.educationalContent

        return VStack(alignment: .leading, spacing: 24) {
            // What it does
            EducationSection(
                title: "What this Protects",
                icon: "shield.fill",
                color: .blue,
                content: educational.explanation
            )

            // How to check/find it
            EducationSection(
                title: "How to Check",
                icon: "gear",
                color: .gray,
                content: educational.howToCheck
            )

            // Why it matters
            EducationSection(
                title: "Why It Matters",
                icon: "exclamationmark.triangle.fill",
                color: .orange,
                content: educational.whyItMatters
            )

            // How to improve
            StepsEducationSection(
                title: "How to Improve",
                icon: "checkmark.circle.fill",
                color: .green,
                steps: educational.improvementSteps
            )

            // Risk scenarios
            ScenariosEducationSection(
                title: "What Could Go Wrong",
                icon: "xmark.circle.fill",
                color: .red,
                scenarios: educational.riskScenarios
            )
        }
    }

    // MARK: - Simple Confirmation Content
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

            // DELETE
        }
    }

    // MARK: - Complex Confirmation Content
    private var complexConfirmationContent: some View {
        VStack(spacing: 20) {
            if config.name == "Location Context" {
                locationContextView
            } else if config.name == "Device Lock Security" {
                deviceLockContextView
            } else if config.name == "Bluetooth Security" {
                bluetoothSecurityContextView
            } else {
                // Fallback to contextual content
                contextualConfirmationContent
            }
        }
    }

    // MARK: - Location Context View
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

    // MARK: - Device Lock View
    private var deviceLockContextView: some View {
        VStack(spacing: 20) {
            if let detector = deviceLockDetector {
                DeviceLockStatusView(detector: detector)

                if detector.biometricAvailable {
                    DeviceBiometricTestView(detector: detector)
                }

                DeviceLockQuestionsView(
                    detector: detector) {
                        // refresh scores after user answers
                        onConfirm(true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onDismiss()
                        }
                    }
            } else {
                Text("Device lock detector not available")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Bluetooth Security View
    private var bluetoothSecurityContextView: some View {
        VStack(spacing: 20) {
            if let bluetoothDetector = bluetoothDetector {
                BluetoothSecurityContextView(
                    detector: bluetoothDetector) { safety in
                        bluetoothDetector.confirmEnvironmentSafety(safety)
                        onConfirm(true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onDismiss()
                        }
                    }
            } else {
                Text("Bluetooth detector not available")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Environmental Security View
    private var environmentalSecurityContextView: some View {
        VStack(spacing: 20) {
            if let detector = environmentDetector {
                EnvironmentalSecurityAssessmentView(
                    detector: detector,
                    showPreciseLocation: $showPreciseLocation,
                    mapRegion: $mapRegion,
                    hideLocationTimer: $hideLocationTimer) {
                        onConfirm(true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onDismiss()
                        }
                    }
            } else {
                Text("Environmental security detector not available")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Action Buttons
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
    private func contextCard(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

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
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

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
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Helper Methods
    private func getNetworkContext() -> String? {
        switch config.name {
        case "VPN Status":
            return "Check Settings > VPN & Device Management > VPN for third-party VPNs, or Settings > Privacy & Security > iCloud Private Relay for Apple's service."
        default:
            return nil
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
                               networkName: "",
                               deviceLockDetector: .init(),
                               bluetoothDetector: .init(),
                               environmentDetector: EnvironmentalSecurityDetector()
    )
}

