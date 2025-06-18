//
//  TabAction.swift
//  SecureState
//
//  Created by Sam Greenhill on 6/13/25.
//

enum TabAction: String, CaseIterable {
    case overview = "Overview"
    case actions = "Actions"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .overview: return "house.fill"
        case .actions: return "bolt.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var title: String {
        return self.rawValue
    }
}
