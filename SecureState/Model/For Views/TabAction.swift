//
//  TabAction.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/13/25.
//

enum TabAction: String, CaseIterable {
    case overview = "Overview"
    case trends = "Trends"
    case tips = "Tips"
    case more = "More"

    var icon: String {
        switch self {
        case .overview: return "house.fill"
        case .trends: return "chart.line.uptrend.xyaxis"
        case .tips: return "lightbulb.fill"
        case .more: return "ellipsis.circle.fill"
        }
    }

    var title: String {
        return self.rawValue
    }
}
