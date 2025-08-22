//
//  MapAnnotation.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/20/25.
//

import SwiftUI
import MapKit

// MARK: Supporting Types

struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

