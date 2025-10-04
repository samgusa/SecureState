//
//  CurrentTimeIndicator.swift
//  SecureState
//
//  Created by Sam Greenhill on 10/2/25.
//

import SwiftUI

struct CurrentTimeIndicator: View {
    let currentHour: Int

    var body: some View {
        let angle = Double(currentHour) * 15.0

        ZStack {
            // Clock hand (line)

            Rectangle()
                .fill(Color.primary)
                .frame(width: 4, height: 60)
                .offset(y: -30) // move pivot to center
                .rotationEffect(.degrees(angle))
                .animation(.easeInOut, value: angle)

            // Arrow Tip
            Triangle()
                .fill(Color.primary)
                .frame(width: 12, height: 12)
                .offset(y: -60)
                .rotationEffect(.degrees(angle))
                .animation(.easeInOut, value: angle)
        }
        .frame(width: 200, height: 200)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.size.width
        let h = rect.size.height
        path.move(to: CGPoint(x: w/2, y: 0))       // top point
        path.addLine(to: CGPoint(x: 0, y: h))      // bottom left
        path.addLine(to: CGPoint(x: w, y: h))      // bottom right
        path.closeSubpath()
        return path
    }
}

#Preview {
    CicadianSecurityClockView(detector: TimeBasedRiskDetector())
}
