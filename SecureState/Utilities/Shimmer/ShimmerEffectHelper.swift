//
//  ShimmerEffectHelper.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import SwiftUI

struct ShimmerEffectHelper: ViewModifier {
    var config: ShimmerConfig
    @State private var moveTo: CGFloat = -0.7
    @State private var timer: Timer?
    @Binding var startAnimation: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                Rectangle()
                    .fill(config.tint)
                    .mask { content }
                    .overlay {
                        GeometryReader { geometry in
                            let size = geometry.size
                            let extraOffset = size.height / 2.5

                            Rectangle()
                                .fill(config.highlight)
                                .mask {
                                    Rectangle()
                                        .fill(
                                            .linearGradient(
                                                colors: [
                                                    .white.opacity(0),
                                                    config.highlight.opacity(config.highlightOpacity),
                                                    .white.opacity(0)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .blur(radius: config.blur)
                                        .rotationEffect(.init(degrees: -70))
                                        .offset(x: moveTo > 0 ? extraOffset : -extraOffset)
                                        .offset(x: size.width * moveTo)
                                }
                        }
                        .mask { content }
                        .opacity(startAnimation ? 1 : 0)
                    }
            }
            .onChange(of: startAnimation) { _, newValue in
                if newValue {
                    startShimmerTimer()
                } else {
                    stopShimmerTimer()
                }
            }
            .onDisappear {
                stopShimmerTimer()
            }
    }

    private func startShimmerTimer() {
        stopShimmerTimer() // always stop existing timer first

        // reset position immediately
        moveTo = -0.7

        // Create a repeating timer for shimmer cycles
        timer = Timer.scheduledTimer(withTimeInterval: config.speed + 0.5, repeats: true) { _ in
            guard startAnimation else {
                stopShimmerTimer()
                return
            }

            performSingleShimmer()
        }

        // Start first shimmer immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            performSingleShimmer()
        }
    }

    private func performSingleShimmer() {
        // reset to start position
        withAnimation(.linear(duration: 0)) {
            moveTo = -0.7
        }

        // Animate Across
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.linear(duration: config.speed)) {
                moveTo = 0.7
            }
        }
    }

    private func stopShimmerTimer() {
        timer?.invalidate()
        timer = nil
        // reset position
        withAnimation(.linear(duration: 0)) {
            moveTo = -0.7
        }
    }
}

