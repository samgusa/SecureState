//
//  RealTimeRecordingIndicator.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/1/25.
//

import SwiftUI

struct RealTimeRecordingIndicator: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var detector: ScreenRecordingDetector
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer pulse ring (only visible when recording)
                if detector.isScreenBeingCaptured {
                    Circle()
                        .stroke(themeManager.currentTheme.dangerColor.opacity(0.3), lineWidth: 4)
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseScale)
                        .opacity(2 - pulseScale) // fades as it expands
                }

                Circle()
                    .fill(detector.isScreenBeingCaptured ? themeManager.currentTheme.dangerColor : themeManager.currentTheme.successColor)
                    .frame(width: 100, height: 100)
                    .scaleEffect(detector.isScreenBeingCaptured ? 1.1 : 1.0)

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
                    .foregroundStyle(detector.isScreenBeingCaptured ? themeManager.currentTheme.dangerColor : themeManager.currentTheme.successColor)

                Text(detector.isScreenBeingCaptured ?
                     "Your screen content is being captured" :
                        "Screen recording protection active")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            // Score display
            HStack {
                Text("Security Score:")
                    .font(.subheadline)

                Text("\(detector.getSecurityScore())/5")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(detector.isScreenBeingCaptured ? themeManager.currentTheme.dangerColor : themeManager.currentTheme.successColor)
            }
        }
        .padding()
        .padding(.top, 5)
        .themedBackground(0.1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func startPulseAnimation() {
        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
            pulseScale = 1.3
        }
    }
}

#Preview {
    let mockThemeManager = ThemeManager()
    RealTimeRecordingIndicator(detector: ScreenRecordingDetector())
        .environmentObject(mockThemeManager)
}
