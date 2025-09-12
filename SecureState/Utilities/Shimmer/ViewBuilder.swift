//
//  ViewBuilder.swift
//  SecureState
//
//  Created by Sam Greenhill on 9/11/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func shimmer(_ config: ShimmerConfig, animation: Binding<Bool>) -> some View {
        self
            .modifier(
                ShimmerEffectHelper(
                    config: config,
                    startAnimation: animation
                )
            )
    }
}
