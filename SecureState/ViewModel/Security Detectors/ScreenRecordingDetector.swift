//
//  ScreenRecordingDetector.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/18/25.
//

import Foundation
import UIKit
import SwiftUI

class ScreenRecordingDetector: ObservableObject {
    @Published var isScreenBeingCaptured: Bool = false

    private var observer: NSObjectProtocol?

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    func startMonitoring() {
        checkInitialState()
        setUpObserver()
    }

    func checkInitialState() {
        DispatchQueue.main.async { [weak self] in
            self?.updateCaptureScreenOnMainThread()
        }
    }

    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.updateCaptureScreenOnMainThread()
            }
        )
    }

    private func updateCaptureScreenOnMainThread() {
        if #available(iOS 17.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first,
               let window = windowScene.windows.first {
                isScreenBeingCaptured = window.traitCollection.sceneCaptureState == .active
            } else {
                isScreenBeingCaptured = UIScreen.main.isCaptured
            }
        } else {
            isScreenBeingCaptured = UIScreen.main.isCaptured
        }
    }

    private func stopMonitoring() {
        if let observer = observer  {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }

    func checkCurrentState() {
        DispatchQueue.main.async { [weak self] in
            self?.updateCaptureScreenOnMainThread()
        }
    }

    func getSecurityScore() -> Int {
        return isScreenBeingCaptured ? 0 : 5
    }

    func getComponentState() -> ComponentState {
        let score = getSecurityScore()
        return .autoDetected(score: score, confidence: .high)
    }

}

