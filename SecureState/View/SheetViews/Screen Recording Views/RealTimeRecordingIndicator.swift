//
//  RealTimeRecordingIndicator.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct RealTimeRecordingIndicator: View {
    @ObservedObject var detector: ScreenRecordingDetector
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer pulse ring (only visible when recording
                if detector.isScreenBeingCaptured {
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 4)
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseScale)
                        .opacity(2 - pulseScale) // fades as expanded
                }

                Circle()
                    .fill(detector.isScreenBeingCaptured ? Color.red : Color.green)
                    .frame(width: 100, height: 100)

                VStack(spacing: 4) {
                    Image(systemName: detector.isScreenBeingCaptured ? "record.circle" : "shield.checkered")
                        .font(.title)
                        .foregroundStyle(.white)

                    Text(detector.isScreenBeingCaptured ? "REC" : "SAFE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .onAppear {
                if detector.isScreenBeingCaptured {
                    startPulseAnimation()
                }
            }
            .onChange(of: detector.isScreenBeingCaptured) { _, isRecording in
                if isRecording {
                    startPulseAnimation()
                }
            }

            VStack(spacing: 4) {
                Text(detector.isScreenBeingCaptured ? "Screen Recording Active" : "No Recording Detected")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(detector.isScreenBeingCaptured ? .red : .green)

                Text(detector.isScreenBeingCaptured ?
                     "Your screen content is being captured" :
                        "Screen recording protection active")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            // Score Display
            HStack {
                Text("Security Score")
                    .font(.subheadline)

                Text("\(detector.getSecurityScore())/5")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(detector.isScreenBeingCaptured ? .red : .green)
            }
        }
        .padding()
        .padding(.top, 5)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func startPulseAnimation() {
        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
            pulseScale = 1.3
        }
    }
}

#Preview {
    RealTimeRecordingIndicator(detector: ScreenRecordingDetector())
}
