//
//  DeviceBiometricTestView.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/12/25.
//

import SwiftUI
import SwiftData

struct DeviceBiometricTestView: View {
    @ObservedObject var detector: DeviceLockSecurityDetector
    @EnvironmentObject var achievementsManager: AchievementsManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingTestResult: Bool = false


    var body: some View {
        VStack(spacing: 16) {
            Text("Test Your \(detector.biometricTypeString)")
                .font(.headline)
                .fontWeight(.medium)

            Text("Tap the button to test if your \(detector.biometricTypeString) is working properly right now.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    let success = await detector.performBiometricTest()
                    showingTestResult = true

                    // TRACK:
                    if success {
                        achievementsManager.trackBiometricTest()
                    }
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
                .background(detector.isTestingBiometric ? Color.gray : themeManager.currentTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(detector.isTestingBiometric)

            if detector.biometricTestPassed {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .themedForeground(themeManager.currentTheme.successColor)

                    Text("\(detector.biometricTypeString) test passed!")
                        .fontWeight(.medium)
                        .themedForeground(themeManager.currentTheme.successColor)
                }
                .padding()
                .background(themeManager.currentTheme.successColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    // We wrap setup code in a closure that returns the view.
    let mockThemeManager = ThemeManager()

    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let view: some View = {
        let achievementManager = AchievementsManager(modelContext: container.mainContext)
        let mockStoreManager = EnhancedStoreManager()
        let freeProManager = ProStatusManager(storeManager: mockStoreManager)
        freeProManager.isPro = false  // not pro

        return DeviceBiometricTestView(detector: .init())
            .environmentObject(freeProManager)
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)

    }()
    return view
}
