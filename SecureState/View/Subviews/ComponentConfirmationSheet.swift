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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    let component: SecurityComponent
    let config: ComponentConfiguration
    let onConfirm: (Bool) -> Void
    let onDismiss: () -> Void

    // Location-specific properties
    let networkName: String?
    let deviceLockDetector: DeviceLockSecurityDetector?
    let bluetoothDetector: EnhancedBluetoothSecurityDetector?
    let environmentDetector: EnvironmentalSecurityDetector?
    let vpnDetector: VPNStatusDetector?
    let screenRecordingDetector: ScreenRecordingDetector?
    let iosVersionDetector: iOSVersionDetector?
    let timeBasedDetector: TimeBasedRiskDetector?

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
        .onDisappear {
            handleDismiss()
        }
    }

    private func handleDismiss() {
        // Reset bluetooth devices is that was the component being viewed
        if config.identifier == .bluetoothSecurity {
            bluetoothDetector?.resetDeviceList()
        }
        onDismiss()
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(component.status.themedColor(theme: themeManager.currentTheme).opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: config.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(component.status.color)
            }

            VStack(spacing: 8) {
                Text(config.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(themeManager.currentTheme.primary)

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
                    .foregroundStyle(selectedMode == mode ? .white : themeManager.currentTheme.primary)
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

            complexConfirmationContent
        }
    }

    private var educationalContent: some View {
        let educational = config.educationalContent

        return VStack(alignment: .leading, spacing: 24) {
            // what it does
            EducationSection(
                title: "What this Protects",
                icon: "shield.fill",
                color: themeManager.currentTheme.primary,
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
                color: themeManager.currentTheme.warningColor,
                content: educational.whyItMatters
            )

            // How to improve
            StepsEducationSection(
                title: "How to Improve",
                icon: "checkmark.circle.fill",
                color: themeManager.currentTheme.successColor,
                steps: educational.improvementSteps
            )

            // Risk scenarios
            ScenariosEducationSection(
                title: "What Could Go Wrong",
                icon: "xmark.circle.fill",
                color: themeManager.currentTheme.dangerColor,
                scenarios: educational.riskScenarios
            )
        }
    }

    // MARK: - Complex Confirmation Content
    private var complexConfirmationContent: some View {
        VStack(spacing: 20) {
            switch config.identifier {
            case .screenRecording:
                screenRecordingContextView
            case .iosVersion:
                iOSVersionContextView
            case .vpnStatus:
                vpnContextView
            case .deviceLock:
                deviceLockContextView
            case .environmentalSecurity:
                environmentalSecurityContextView
            case .timeBasedRisk:
                timeContextView
            case .bluetoothSecurity:
                bluetoothSecurityContextView
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

    // MARK: - VPN Context View
    private var vpnContextView: some View {
        VStack(spacing: 20) {
            if let detector = vpnDetector {
                VPNTrafficSimulatorView(
                    detector: detector) { confirmed in
                        onConfirm(confirmed)
                        onDismiss()
                    }
            } else {
                Text("VPN security detector not available")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Time Context View
    private var timeContextView: some View {
        VStack(spacing: 20) {
            if let detector = timeBasedDetector {
                CicadianSecurityClockView(detector: detector)
            } else {
                Text("Time-based security detector not available")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Screen Recording Context View
    private var screenRecordingContextView: some View {
        VStack(spacing: 20) {
            if let detector = screenRecordingDetector {
                ScreenRecordingStatusView(detector: detector)
            } else {
                Text("Screen Recording security detector not available")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - iOS Version Context View
    private var iOSVersionContextView: some View {
        VStack(spacing: 20) {
            if let detector = iosVersionDetector {
                iOSVersionFreshnessView(detector: detector) { confirmed in
                    onConfirm(confirmed)
                    onDismiss()
                }
            } else {
                Text("iOS Version security detector not available")
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
}

#Preview {
    let mockThemeManager = ThemeManager()

    ComponentConfirmationSheet(
        component: SecurityComponent(
            identifier: .screenRecording,
            score: 15,
            maxScore: 20,
            icon: "shield"
        ),
        config: ComponentConfiguration(
            identifier: .iosVersion,
            icon: "wifi",
            title: "iOS Version Status",
            description: "Keeping iOS updated is crucial for security.",
            question: "Is your iOS version up to date?",
            positiveText: "Yes, I'm up to date",
            negativeText: "No, update available"
           ),
        onConfirm: { _ in },
        onDismiss: {},
        networkName: "",
        deviceLockDetector: DeviceLockSecurityDetector(),
        bluetoothDetector: EnhancedBluetoothSecurityDetector(),
        environmentDetector: EnvironmentalSecurityDetector(),
        vpnDetector: VPNStatusDetector(),
        screenRecordingDetector: ScreenRecordingDetector(),
        iosVersionDetector: iOSVersionDetector(),
        timeBasedDetector: TimeBasedRiskDetector()
    )
    .environmentObject(mockThemeManager)
}

