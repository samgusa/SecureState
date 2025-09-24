//
//  DeviceBiometricTestView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/12/25.
//

import SwiftUI

struct DeviceBiometricTestView: View {
    @ObservedObject var detector: DeviceLockSecurityDetector
    @State private var showingTestResult: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Test your \(detector.biometricTypeString)")
                .font(.headline)
                .fontWeight(.medium)

            Text("Tap the button to test if your \(detector.biometricTypeString) is working properly right now.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    _ = await detector.performBiometricTest()
                    showingTestResult = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showingTestResult = false
                    }
                }
            } label: {
                HStack {
                    if detector.isTestingBiometric {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: detector.biometricType == .faceID ? "faceid" : "touchid")
                            .font(.title2)
                    }

                    Text(detector.isTestingBiometric ? "Testing..." : "Test \(detector.biometricTypeString)")
                        .fontWeight(.medium)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(detector.isTestingBiometric ? Color.gray : Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(detector.isTestingBiometric)

            if detector.biometricTestPassed {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)

                    Text("\(detector.biometricTypeString) test passed!")
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    DeviceBiometricTestView(detector: .init())
}
