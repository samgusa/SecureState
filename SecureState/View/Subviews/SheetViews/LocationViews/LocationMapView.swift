//
//  LocationMapView.swift
//  SecureState
//
//  Created by Sam Greenhill on 8/20/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct LocationMapView: View {
    let snapshot: EnhancedLocationContextDetector.LocationSnapshot
    @Binding var showPreciseLocation: Bool
    @Binding var mapRegion: MKCoordinateRegion
    @Binding var hideLocationTimer: Timer?

    // Better zoom level for street visibility
    private var streetLevelRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: snapshot.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.008,
                longitudeDelta: 0.008
            )
        )
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Detected Location")
                        .font(.headline)

                    Text(snapshot.detectedInfo.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if snapshot.detectedInfo.detailDescription.isEmpty {
                        Text(snapshot.detectedInfo.detailDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Accuracy Indicator
                VStack(alignment: .trailing, spacing: 2) {
                    Text("±\(Int(snapshot.accuracy))m")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if snapshot.isAccurate {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    } else {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal)

            // Updated Map with modern MapKit
            ZStack {
                if #available(iOS 17.0, *) {
                    Map(initialPosition: .region(streetLevelRegion)) {
                        if showPreciseLocation {
                            Marker("Current Location", coordinate: snapshot.coordinate)
                                .tint(.red)
                        }
                    }
                    .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport, .hospital, .school])))
                    .mapControls {
                        MapCompass()
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(true)
                } else {
                    // Fall back for iOS 16 and earlier
                    Map(coordinateRegion: .constant(streetLevelRegion),
                        interactionModes: [],
                        showsUserLocation: false,
                        annotationItems: showPreciseLocation ? [MapAnnotation(coordinate: snapshot.coordinate)] : []) { annotation in
                        MapPin(coordinate: annotation.coordinate, tint: .red)
                    }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                }

                // Blur overlay when location is hidden
                if !showPreciseLocation {
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.1),
                                        Color.black.opacity(0.3),
                                        Color.black.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background(.regularMaterial)

                        VStack(spacing: 8) {
                            Image(systemName: "eye.slash.fill")
                                .font(.title2)
                                .foregroundStyle(.primary)

                            Text("Press & Hold to Reveal")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            // Subtle indication of map content beneath
                            Text("Street map ready")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                // Reveal precise location temporarily
                withAnimation(.easeInOut(duration: 0.3)) {
                    showPreciseLocation = true
                }

                // Auto-hide after 3 seconds
                hideLocationTimer?.invalidate()
                hideLocationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showPreciseLocation = false
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

#Preview {
    Home()
}

