//
//  SScoreView.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct SScoreView: View {
    @Binding var animateScore: Bool
    var situationalPercentage: Double
    var situationalGradient: LinearGradient
    var devicePercentage: Double
    var deviceGradient: LinearGradient
    @Binding var selectedSection: SecuritySection?
    @State var selectedTab: TabAction = .overview
    @State var scrollOffset: CGFloat = 0
    @Binding var situationalScore: Double
    @Binding var deviceScore: Double

    let maxDeviceScore: Double = 55
    let maxSituationalScore: Double = 45

    var body: some View {
        ZStack {
            // Background S Shape with subtle shadow
            SShapePath()
                .stroke(Color(.systemGray5), lineWidth: 20)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)

            // Situational Awareness (Top curve)
            SShapePath()
                .trim(from: 0, to: animateScore ? 0.5 * situationalPercentage : 0)
                .stroke(
                    situationalGradient,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .animation(.easeInOut(duration: 1.2).delay(0.3), value: animateScore)
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedSection = selectedSection == .situational ? nil : .situational
                        selectedTab = .overview
                    }
                }

            // Device Security (Bottom curve)
            SShapePath()
                .trim(from: 0.5, to: animateScore ? (0.5 + (0.5 * devicePercentage)) : 0.5)
                .stroke(
                    deviceGradient,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .animation(.easeInOut(duration: 1.2).delay(0.6), value: animateScore)
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedSection = selectedSection == .device ? nil : .device
                        selectedTab = .overview
                    }
                }

            // Subtle floating Score indicators (only visible when not scrolled)
            if scrollOffset > -50 {
                VStack(spacing: 180) {
                    // Situational score (top right) - more subtle
                    HStack {
                        Spacer()
                        FloatingScoreIndicator(
                            score: Int(situationalScore),
                            maxScore: Int(maxSituationalScore),
                            isSelected: selectedSection == .situational//,
                        //  animate: $animateScore,
                        //  delay: 0.9
                        )
                        .offset(x: -40, y: -20)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedSection = selectedSection == .situational ? nil : .situational
                                selectedTab = .overview
                            }
                        }
                    }

                    // Device score (bottom left) - more subtle
                    HStack {
                        FloatingScoreIndicator(
                            score: Int(deviceScore),
                            maxScore: Int(maxDeviceScore),
                            isSelected: selectedSection == .device//,
                        //  animate: $animateScore,
                        //  delay: 0.9
                        )
                        .offset(x: 40, y: 20)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedSection = selectedSection == .device ? nil : .device
                                //selectedTab = .overview
                            }
                        }
                        Spacer()
                    }
                }
                .opacity(scrollOffset > -50 ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.3), value: scrollOffset)
            }
        }
    }
}

#Preview {
    SScoreView(
        animateScore: .constant(true),
        situationalPercentage: 0.8,
        situationalGradient: LinearGradient(
            colors: [
                .green,
                .mint
            ],
            startPoint: .topLeading,
            endPoint: .center
        ),
        devicePercentage: 0.5,
        deviceGradient: LinearGradient(
            colors: [.red, .pink],
            startPoint: .topLeading,
            endPoint: .center
        ),
        selectedSection: .constant(.situational),
        situationalScore: .constant(28),
        deviceScore: .constant(22)
    )
}
