//
//  ScreenRecordingStatusView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct ScreenRecordingStatusView: View {
    @ObservedObject var detector: ScreenRecordingDetector
    @State private var showTestInstructions: Bool = false
    @State private var hasTestedFeature: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            // Real time status indicator
            RealTimeRecordingIndicator(detector: detector)

            VStack(spacing: 16) {
                Text("Test This Feature")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Follow these steps to see how screen recording detection works:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if !hasTestedFeature {
                    Button("Show Test Instructions") {
                        withAnimation(.spring()) {
                            showTestInstructions.toggle()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                if showTestInstructions {
                    ScreenRecordingTestInstructions {
                        hasTestedFeature = true
                        showTestInstructions = false
                    }
                }

                if hasTestedFeature {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Feature tested successfully!")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            // Security Impact Information
            ScreenRecordingSecurityImpact()
        }
    }
}

#Preview {
    ScreenRecordingStatusView(detector: ScreenRecordingDetector())
}
