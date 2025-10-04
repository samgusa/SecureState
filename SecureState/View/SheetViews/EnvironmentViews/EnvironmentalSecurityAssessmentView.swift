//
//  EnvironmentalSecurityAssessmentView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/25/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct EnvironmentalSecurityAssessmentView: View {
    @ObservedObject var detector: EnvironmentalSecurityDetector
    @Binding var showPreciseLocation: Bool
    @Binding var mapRegion: MKCoordinateRegion
    @Binding var hideLocationTimer: Timer?
    let onComplete: () -> Void

    @State private var selectedStep: AssessmentStep = .network

    enum AssessmentStep: String, CaseIterable {
        case network = "Network"
        case location = "Location"
        case summary = "Summary"
    }

    var body: some View {
        VStack(spacing: 20) {
            // Assessment tab selector
            assessmentProgressView

            switch selectedStep {
            case .network:
                networkAssessmentContent
            case .location:
                locationAssessmentContent
            case .summary:
                summaryAssessmentContent
            }
        }
    }

    private func completeAssessment() {
        // Trigger small delay to ensure all detector state is update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onComplete()
        }
    }

    private var assessmentProgressView: some View {
        HStack(spacing: 0) {
            ForEach(Array(AssessmentStep.allCases.enumerated()), id: \.element) { index, step in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(getStepColor(step))
                            .frame(width: 32, height: 32)

                        if isStepCompleted(step) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .font(.system(size: 12, weight: .bold))
                        } else {
                            Text("\(index + 1)")
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .onTapGesture {
                        if canNavigateToStep(step) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedStep = step
                            }
                        }
                    }
                    // connecting line (except last step)
                    if index < AssessmentStep.allCases.count - 1 {
                        Rectangle()
                            .fill(isStepCompleted(AssessmentStep.allCases[index + 1]) ? .green : Color(.systemGray4))
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func getStepColor(_ step: AssessmentStep) -> Color {
        if selectedStep == step {
            return .blue
        } else if isStepCompleted(step) {
            return .green
        } else {
            return Color(.systemGray4)
        }
    }

    private func isStepCompleted(_ step: AssessmentStep) -> Bool {
        switch step {
        case .network:
            return detector.networkType == .cellular || detector.networkTrustLevel != nil
        case .location:
            return detector.environmentType != nil
        case .summary:
            return isStepCompleted(.network) && isStepCompleted(.location)
        }
    }

    private func canNavigateToStep(_ step: AssessmentStep) -> Bool {
        switch step {
        case .network:
            return true
        case .location:
            return true
        case .summary:
            return isStepCompleted(.network) && isStepCompleted(.location)
        }
    }

    private var networkAssessmentContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Network Connection Assessment")
                .font(.headline)
                .fontWeight(.semibold)

            // Score breakdown explanation
            scoreBreakdownCard

            // Current network status
            HStack(spacing: 12) {
                Image(systemName: detector.networkType == .cellular ? "antenna.radiowaves.left.and.right" : "wifi")
                    .foregroundStyle(getNetworkColor())
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(detector.networkType.description)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if detector.networkType == .wifi {
                        if let trustLevel = detector.networkTrustLevel {
                            Text(trustLevel.description)
                                .font(.caption)
                                .foregroundStyle(getTrustColor(trustLevel))
                        } else {
                            Text("Trust level unknown - confirmation needed")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    } else {
                        Text("Private encrypted connection through carrier")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                Spacer()

                HStack(spacing: 2) {
                    Text("\(detector.getNetworkScore())")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(getNetworkColor())

                    Text("/ 15 pts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Network trust confirmation for Wi-Fi
            if detector.networkType == .wifi && detector.networkTrustLevel == .unknown {
                networkTrustExplanation
            }

            // Network Security tips
            networkSecurityTips
        }
    }

    private var scoreBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Network Scoring (0-15 points)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)

            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundStyle(.green)
                        .frame(width: 20)
                    Text("Cellular Connection")
                        .font(.caption)
                    Spacer()
                    Text("15 pts")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                }

                HStack {
                    Image(systemName: "wifi")
                        .foregroundStyle(.blue)
                        .frame(width: 20)
                    Text("Trusted Wi-Fi (home/work)")
                        .font(.caption)
                    Spacer()
                    Text("12 pts")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                }

                HStack {
                    Image(systemName: "wifi")
                        .foregroundStyle(.orange)
                        .frame(width: 20)
                    Text("Unknown Wi-Fi")
                        .font(.caption)
                    Spacer()
                    Text("8 pts")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                }

                HStack {
                    Image(systemName: "wifi")
                        .foregroundStyle(.red)
                        .frame(width: 20)
                    Text("Public Wi-Fi (confirmed)")
                        .font(.caption)
                    Spacer()
                    Text("3 pts")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        }
    }

    private var networkTrustExplanation: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wi-Fi Network Trust Level")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Since iOS protects network names for privacy, we need you to tell us about this Wi-Fi network.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Simple visual scoring guide
            VStack(spacing: 8) {
                networkScoreRow("Trusted Network", "12 points", .green, "house.badge.wifi.fill") {
                    Text("Networks you control: your home, your office")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                networkScoreRow("Unknown Network", "8 points", .orange, "wifi.circle") {
                    Text("Current default - need your input to improve")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                networkScoreRow("Public Network", "3 points", .red, "wifi.exclamationmark") {
                    Text("Shared networks: coffee shops, hotels, airports")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("Choose the option that best describes this Wi-Fi network:")
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(spacing: 12) {
                Button {
                    detector.confirmNetworkTrust(true)
                    if detector.environmentType != nil {
                        selectedStep = .summary
                    }
                } label: {
                    HStack {
                        Image(systemName: "house.badge.wifi")
                            .foregroundStyle(.white)
                        Text("This is my home/work network")
                            .fontWeight(.medium)
                        Spacer()
                        Text("+4 points")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    detector.confirmNetworkTrust(false)
                    if detector.environmentType != nil {
                        selectedStep = .summary
                    }
                } label : {
                    HStack {
                        Image(systemName: "wifi.exclamationmark")
                            .foregroundStyle(.white)
                        Text("This is a public/shared network")
                            .fontWeight(.medium)
                        Spacer()
                        Text("-5 points")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // Show current selection if made
            if let confirmed = detector.userConfirmedNetworkType {
                HStack(spacing: 8) {
                    Image(systemName: confirmed ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(confirmed ? .green : .orange)

                    Text(confirmed ?
                         "Network confirmed as trusted (+4 points to score)" :
                            "Network confirmed as public (-5 points to score)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background((confirmed ? Color.green : Color.orange).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    @ViewBuilder
    private func networkScoreRow<Content: View>(_ title: String, _ points: String, _ color: Color, _ icon: String, @ViewBuilder description: () -> Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                description()
            }
            Spacer()

            Text(points)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    private var networkSecurityTips: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.orange)
                Text("Network Security Tips")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            VStack(alignment: .leading, spacing: 4) {
                tipRow("Switch to cellular data in public spaces for maximum security", icon: "antenna.radiowaves.left.and.right")
                tipRow("Use VPN on any shared network to encrypt your traffic", icon: "shield.fill")
                tipRow("Avoid banking and passwords on unknown Wi-Fi networks", icon: "creditcard.fill")
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func tipRow(_ text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
                .font(.caption)
                .frame(width: 16)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
    }

    private var locationAssessmentContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Physical Environment Assessment")
                .font(.headline)
                .fontWeight(.semibold)

            // Location detection status
            EnvironmentLocationDetectionStatusView(detector: detector)

            // MapView if location is available
            if let snapshot = detector.currentLocationSnapshot {
                EnvironmentLocationMapView(
                    snapshot: snapshot,
                    showPreciseLocation: $showPreciseLocation,
                    mapRegion: $mapRegion,
                    hideLocationTimer: $hideLocationTimer
                )
            }

            // Environment type selection
            environmentTypeSelection
        }
    }

    private var environmentTypeSelection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select your current environment type:")
                .font(.subheadline)
                .fontWeight(.medium)

            LazyVStack(spacing: 8) {
                ForEach(EnvironmentalSecurityDetector.EnvironmentType.allCases, id: \.rawValue) { environment in
                    Button {
                        detector.selectEnvironmentType(environment)
                        if detector.networkType == .cellular || detector.networkTrustLevel != nil {
                            selectedStep = .summary
                        }
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(environment.color.opacity(0.1))
                                    .frame(width: 36, height: 36)

                                Image(systemName: environment.icon)
                                    .font(.system(size: 16))
                                    .foregroundStyle(environment.color)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(environment.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)

                                Text(environment.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if detector.environmentType == environment {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else {
                                Text("+\(environment.scoreModifier)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(environment.color)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            detector.environmentType == environment ? environment.color.opacity(0.1) : Color(.systemGray6)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    detector.environmentType == environment ?
                                    environment.color : Color.clear,
                                    lineWidth: 2
                                )
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var summaryAssessmentContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Environmental Security Summary")
                .font(.headline)
                .fontWeight(.semibold)

            // Score breakdown
            VStack(spacing: 12) {
                HStack {
                    Text("Network Security:")
                        .font(.subheadline)
                    Spacer()
                    Text("\(detector.getNetworkScore()) points")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(getNetworkColor())
                }

                HStack {
                    Text("Environment Modifier")
                        .font(.subheadline)
                    Spacer()
                    Text("+\(detector.getEnvironmentModifier()) points")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(detector.environmentType?.color ?? .gray)
                }
                Divider()

                HStack {
                    Text("Total Environmental Score:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(detector.getEnvironmentScore())/25")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(getScoreColor(detector.getEnvironmentScore()))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Recommendations
            VStack(alignment: .leading, spacing: 8) {
                Text("Recommendations:")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                ForEach(detector.getRecommendationsForCurrentScore(), id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)

                        Text(recommendation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            if allAssessmentComplete {
                Button("Complete Assessment") {
                    completeAssessment()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    private var allAssessmentComplete: Bool {
        // Network assessment complete
        let networkComplete = detector.networkType == .cellular || detector.networkTrustLevel != nil
        // Environment assessment complete
        let environmentComplete = detector.environmentType != nil

        return networkComplete && environmentComplete
    }

    private func getNetworkColor() -> Color {
        switch detector.networkType {
        case .cellular: return .green
        case .wifi:
            guard let trust = detector.networkTrustLevel else { return .orange }
            return getTrustColor(trust)
        case .unknown: return .gray
        }
    }

    private func getTrustColor(_ trust: EnvironmentalSecurityDetector.NetworkTrustLevel) -> Color {
        switch trust {
        case .trusted: return .green
        case .isPublic: return .red
        case .unknown: return .orange
        }
    }

    private func getScoreColor(_ score: Int) -> Color {
        switch score {
        case 20...25: return .green
        case 10...19: return .orange
        case 0...9: return .red
        default: return .gray
        }
    }

}


#Preview {
    EnvironmentalSecurityAssessmentView(
        detector: EnvironmentalSecurityDetector(),
        showPreciseLocation: .constant(false),
        mapRegion: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.011286, longitude: -116.166868),
            span: MKCoordinateSpan(
                latitudeDelta: 0.008,
                longitudeDelta: 0.008
            )
        )),
        hideLocationTimer: .constant(nil)) {

        }
}

