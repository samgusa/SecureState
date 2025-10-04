//
//  iOSVersionFreshnessView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct iOSVersionFreshnessView: View {
    @ObservedObject var detector: iOSVersionDetector
    let onSelection: (Bool) -> Void

    @State private var daysSinceLastConfirmation: Int = 0
    @State private var showUpdatePrompt: Bool = false


    var body: some View {
        VStack(spacing: 24) {
            // Current Version Status
            iOSVersionStatusView(detector: detector)

            // Freshness Meter
            VersionFreshnessMeter(
                detector: detector,
                daysSinceConfirmation: daysSinceLastConfirmation
            )

            // Apple's release cycle information
            AppleReleaseCycleInfo()

            // Update check section
            UpdateCheckSecton(
                onConfirmation: onSelection
            )

            // freshness degradation explanation
            FreshnessDegradationExplanation()
        }
        .onAppear {
            daysSinceLastConfirmation = detector.daysSinceLastConfirmation
        }
    }
}

#Preview {
    iOSVersionFreshnessView(detector: iOSVersionDetector(), onSelection: { _ in
    })
}
