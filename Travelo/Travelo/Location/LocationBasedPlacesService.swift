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
        nearbyPlaces = [] // Clear existing places immediately
        
        // Expanded search with more specific and general terms
        let searchTypes = [
            // Food & Dining
            "restaurant",
            "fast food",
            "cafe",
            "bakery",
            "food",
            
            // Shopping & Essential Services
            "store",
            "grocery store", 
            "supermarket",
            "pharmacy",
            "gas station",
            "fuel",
            
            // Financial & Basic Services
            "bank",
            "ATM",
            "post office",
            
            // Healthcare & Emergency
            "hospital",
            "clinic",
            "urgent care",
            
            // Tourism & Recreation
            "tourist attraction",
            "museum",
            "park",
            "landmark",
            "hotel",
            "lodging",
            "accommodation",
            "inn",
            "motel",
            
            // Transportation
            "airport",
            "train station",
            "bus stop",
            
            // Entertainment
            "shopping center",
            "mall"
        ]
        
        var allPlaces: [MKMapItem] = []
        let dispatchGroup = DispatchGroup()
        
        for searchType in searchTypes {
            dispatchGroup.enter()
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchType
            // Significantly expanded search area
            request.region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)  // Much wider area
            )
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                defer { dispatchGroup.leave() }
                
                if let response = response {
                    print("🔍 Found \(response.mapItems.count) results for '\(searchType)'")
                    
                    // Get places within expanded distance
                    let filteredPlaces = response.mapItems
                        .filter { item in
                            guard let location = item.placemark.location else { return false }
                            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                .distance(from: location)
                            return distance <= 50000 // Expanded to 50km
                        }
                        .prefix(6) // More results per category
                    
                    print("📍 After filtering: \(filteredPlaces.count) places for '\(searchType)'")
                    allPlaces.append(contentsOf: filteredPlaces)
                } else if let error = error {
                    print("❌ Search error for \(searchType): \(error.localizedDescription)")
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("🏁 Total places found before deduplication: \(allPlaces.count)")
            
            // Remove duplicates and shuffle for variety
            let uniquePlaces = Array(Set(allPlaces.map { $0.name ?? "" }))
                .compactMap { name in allPlaces.first { $0.name == name } }
                .shuffled() // Add randomness
                .prefix(30) // Show up to 30 places (increased from 20)
            
            self.nearbyPlaces = Array(uniquePlaces)
            self.isLoading = false
            
            print("✅ Final places shown: \(self.nearbyPlaces.count)")
            
            // Log the types of places we found
            for place in self.nearbyPlaces {
                let category = place.pointOfInterestCategory?.rawValue ?? "No category"
                print("📋 \(place.name ?? "Unknown"): \(category)")
            }
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