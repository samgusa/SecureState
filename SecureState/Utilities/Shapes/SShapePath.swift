//
//  SShapePath.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/12/25.
//

import SwiftUI

struct SShapePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        let centerY = height / 2

        // More pronounced S-curve with better proportions
        path.move(to: CGPoint(x: centerX + 100, y: centerY - 160))

        // Top curve - situational (more dramatic curve)
        path.addCurve(
            to: CGPoint(x: centerX - 80, y: centerY - 40),
            control1: CGPoint(x: centerX - 20, y: centerY - 160),
            control2: CGPoint(x: centerX - 80, y: centerY - 100)
        )

        // Middle transition (smoother connection)
        path.addCurve(
            to: CGPoint(x: centerX + 80, y: centerY + 40),
            control1: CGPoint(x: centerX - 80, y: centerY + 20),
            control2: CGPoint(x: centerX + 80, y: centerY - 20)
        )

        // Bottom curve - device (more dramatic curve)
        path.addCurve(
            to: CGPoint(x: centerX - 100, y: centerY + 160),
            control1: CGPoint(x: centerX + 80, y: centerY + 100),
            control2: CGPoint(x: centerX + 20, y: centerY + 160)
        )

        return path
    }
}

#Preview {
    SShapePath()
}
