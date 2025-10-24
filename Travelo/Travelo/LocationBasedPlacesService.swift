//
//  LocationBasedPlacesService.swift
//  Travelo
//
//  Created by Dawar Hasnain on 10/24/25.
//

import Foundation
import MapKit
import CoreLocation
import Combine

@MainActor
class LocationBasedPlacesService: NSObject, ObservableObject {
    @Published var nearbyPlaces: [MKMapItem] = []
    @Published var isLoading = false
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func searchNearbyPlaces(around coordinate: CLLocationCoordinate2D) {
        isLoading = true
        
        // Create multiple search requests for different types of places
        let searchTypes = [
            "tourist attraction",
            "restaurant", 
            "museum",
            "park",
            "landmark",
            "shopping",
            "entertainment",
            "cafe",
            "hotel",
            "gas station",
            "pharmacy",
            "bank",
            "hospital",
            "library",
            "church",
            "school"
        ]
        
        var allPlaces: [MKMapItem] = []
        let dispatchGroup = DispatchGroup()
        
        for searchType in searchTypes {
            dispatchGroup.enter()
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchType
            request.region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            )
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                defer { dispatchGroup.leave() }
                
                if let response = response {
                    // Filter out places that are too far and get more results per category
                    let filteredPlaces = response.mapItems
                        .filter { item in
                            guard let location = item.placemark.location else { return false }
                            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                .distance(from: location)
                            return distance <= 75000 // Within 75km (expanded)
                        }
                        .prefix(5) // Increased to top 5 per category
                    
                    allPlaces.append(contentsOf: filteredPlaces)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // Remove duplicates and limit total results
            let uniquePlaces = Array(Set(allPlaces.map { $0.name ?? "" }))
                .compactMap { name in allPlaces.first { $0.name == name } }
                .prefix(24) // Increased from 12 to 24 places
            
            self.nearbyPlaces = Array(uniquePlaces)
            self.isLoading = false
        }
    }
    
    func updateRegion(for coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        userLocation = coordinate
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationBasedPlacesService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            // Use selected country's location as fallback
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        
        updateRegion(for: coordinate)
        searchNearbyPlaces(around: coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        // Could fallback to selected country location
    }
}