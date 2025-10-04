//
//  CicadianSecurityClockView.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct CicadianSecurityClockView: View {
    @ObservedObject var detector: TimeBasedRiskDetector

    @State private var selectedHour: Int?
    @State private var currentTime = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            // Current Status Header
            TimeRiskStatusView(detector: detector)

            // Interactive Clock
            VStack(spacing: 16) {
                Text("24-Hour Security Risk Assessment")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Tap different times to see risk explanations")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Clock Face
                ZStack {
                    // Background Circle
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 200, height: 200)
                        .overlay {
                            Circle()
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        }
                    // Risk Zones
                    ForEach(0..<24, id: \.self) { hour in
                        let angle = Double(hour) * 15.0 - 90.0 // Convert to degrees, offset by 90
                        let riskLevel = detector.determineRiskLevel(for: hour)

                        Path { path in
                            let center = CGPoint(x: 100, y: 100)
                            path.move(to: center)
                            path.addArc(
                                center: center,
                                radius: 90,
                                startAngle: .degrees(angle - 7.5),
                                endAngle: .degrees(angle + 7.5),
                                clockwise: false
                            )
                        }
                        .fill(riskLevel.color.opacity(selectedHour == hour ? 0.8 : 0.3))
                        .shadow(color: .black.opacity(selectedHour == hour ? 0.4 : 0), radius: 5, x: 3, y: 3)
                        .scaleEffect(selectedHour == hour ? 1.2 : 1.0)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedHour = selectedHour == hour ? nil : hour
                            }
                        }
                    }

                    // Hour Markers
                    ForEach([0, 6, 12, 18], id: \.self) { hour in
                        let angle = Double(hour) * 15.0 - 90.0
                        let radians = angle * .pi / 180
                        let x = 100 + 75 * cos(radians)
                        let y = 100 + 75 * sin(radians)

                        Text("\(hour == 0 ? 12 : hour > 12 ? hour - 12 : hour)\(hour < 12 ? "AM" : "PM")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .position(x: x, y: y)
                    }
                    // Current time Indicator
                    CurrentTimeIndicator(currentHour: detector.currentHour)

                    // Center dot
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 8, height: 8)
                }
                .frame(width: 200, height: 200)
            }

            // Risk explanation for selected of current hour
            if let selectedHour = selectedHour {
                HourRiskExplanationView(
                    hour: selectedHour,
                    riskLevel: detector.determineRiskLevel(for: selectedHour)
                )
            } else {
                HourRiskExplanationView(
                    hour: detector.currentHour,
                    riskLevel: detector.currentTimeRisk
                )
            }

            // Alertness meter
            AlertnessMeterView(
                hour: selectedHour ?? detector.currentHour,
                riskLevel: selectedHour != nil ?
                detector.determineRiskLevel(for: selectedHour ?? 0):
                    detector.currentTimeRisk
            )
        }
        .onReceive(timer) { _ in
            currentTime = Date()
            detector.checkCurrentTime()
        }
    }
}

#Preview {
    CicadianSecurityClockView(detector: TimeBasedRiskDetector())
}
