//
//  PlaceDetailsService.swift
//  Travelo
//
//  Created by Dawar Hasnain on 10/24/25.
//

import Foundation
import MapKit
import SwiftUI
import Combine

// Enhanced place data with description and images
struct PlaceDetails {
    let name: String
    let description: String
    let imageUrls: [String]
    let rating: Double?
    let reviewCount: Int?
    let priceLevel: String?
    let website: String?
    let phoneNumber: String?
}

@MainActor
class PlaceDetailsService: ObservableObject {
    @Published var placeDetails: PlaceDetails?
    @Published var isLoading = false
    
    // For demo purposes, I'll create realistic descriptions and use placeholder image service
    // In production, you'd integrate with Google Places API, Foursquare, or similar
    
    func fetchPlaceDetails(for place: MKMapItem) async {
        isLoading = true
        
        // Use MapKit to get detailed place information from Apple's database
        let details = await fetchAppleMapsPlaceDetails(for: place)
        
        await MainActor.run {
            self.placeDetails = details
            self.isLoading = false
        }
    }
    
    private func fetchAppleMapsPlaceDetails(for place: MKMapItem) async -> PlaceDetails {
        let name = place.name ?? "Unknown Place"
        var description = ""
        var website: String? = place.url?.absoluteString
        var phoneNumber: String? = place.phoneNumber
        
        // Try to get more detailed information from MapKit
        do {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = name
            request.region = MKCoordinateRegion(
                center: place.placemark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            
            // Find the exact match or closest match
            if let matchedPlace = response.mapItems.first(where: { item in
                // Check if it's the same place by name and proximity
                guard let itemName = item.name, let placeName = place.name else { return false }
                let nameMatch = itemName.lowercased().contains(placeName.lowercased()) || 
                               placeName.lowercased().contains(itemName.lowercased())
                
                let coordinate1 = item.placemark.coordinate
                let coordinate2 = place.placemark.coordinate
                let proximityMatch = abs(coordinate1.latitude - coordinate2.latitude) < 0.001 &&
                                   abs(coordinate1.longitude - coordinate2.longitude) < 0.001
                
                return nameMatch || proximityMatch
            }) {
                
                // Get additional details from the matched place
                website = matchedPlace.url?.absoluteString ?? website
                phoneNumber = matchedPlace.phoneNumber ?? phoneNumber
                
                // Extract description from MapKit data
                description = extractDescriptionFromMapItem(matchedPlace)
            }
        } catch {
            print("MapKit search error: \(error)")
        }
        
        // If we couldn't get a good description, create a simple one
        if description.isEmpty {
            description = generateSimpleDescription(name: name, place: place)
        }
        
        return PlaceDetails(
            name: name,
            description: description,
            imageUrls: [], // No images as requested
            rating: nil,   // MapKit doesn't provide ratings
            reviewCount: nil,
            priceLevel: nil,
            website: website,
            phoneNumber: phoneNumber
        )
    }
    
    private func extractDescriptionFromMapItem(_ item: MKMapItem) -> String {
        let name = item.name ?? "This location"
        
        // Build description using available MapKit information
        var components: [String] = []
        
        // Add basic location info
        if let thoroughfare = item.placemark.thoroughfare {
            components.append("located on \(thoroughfare)")
        }
        
        if let locality = item.placemark.locality {
            components.append("in \(locality)")
        }
        
        // Create contextual description based on category
        if let category = item.pointOfInterestCategory {
            let categoryName = category.rawValue.replacingOccurrences(of: "MKPOICategory", with: "")
                .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
                .capitalized.lowercased()
            
            let locationInfo = components.isEmpty ? "" : " \(components.joined(separator: ", "))"
            
            switch categoryName {
            case let c where c.contains("restaurant"):
                return "\(name) is a restaurant\(locationInfo). Contact them for menu information, hours, and reservations."
            case let c where c.contains("gas"):
                return "\(name) is a gas station\(locationInfo) providing fuel and convenience services."
            case let c where c.contains("hospital") || c.contains("medical"):
                return "\(name) is a medical facility\(locationInfo) providing healthcare services to the community."
            case let c where c.contains("bank") || c.contains("atm"):
                return "\(name) is a financial institution\(locationInfo) offering banking services."
            case let c where c.contains("store") || c.contains("shop"):
                return "\(name) is a retail location\(locationInfo) offering various products and services."
            case let c where c.contains("hotel"):
                return "\(name) provides accommodation services\(locationInfo). Contact them for room availability and rates."
            case let c where c.contains("park"):
                return "\(name) is a park\(locationInfo) offering outdoor recreation and green space."
            case let c where c.contains("museum"):
                return "\(name) is a museum\(locationInfo) featuring exhibits and educational displays."
            case let c where c.contains("library"):
                return "\(name) is a library\(locationInfo) providing books, resources, and community services."
            default:
                return "\(name) is a \(categoryName)\(locationInfo). Contact them directly for more information about their services."
            }
        }
        
        // Fallback without category
        let locationInfo = components.isEmpty ? "" : " located \(components.joined(separator: ", "))"
        return "\(name) is a local business\(locationInfo). Contact them directly for information about their services and hours."
    }
    
    private func generateSimpleDescription(name: String, place: MKMapItem) -> String {
        // Very simple fallback description
        if let category = place.pointOfInterestCategory {
            let categoryName = category.rawValue.replacingOccurrences(of: "MKPOICategory", with: "")
                .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
                .capitalized.lowercased()
            
            return "\(name) is a local \(categoryName). Use the contact information below to learn more."
        } else {
            return "\(name) is a local business. Contact them directly for more information."
        }
    }
    
    private func generatePriceLevel(category: String) -> String? {
        switch category.lowercased() {
        case let c where c.contains("restaurant") || c.contains("food"):
            return ["$", "$$", "$$$"].randomElement()
        case let c where c.contains("hotel"):
            return ["$$", "$$$", "$$$$"].randomElement()
        case let c where c.contains("shop") || c.contains("store"):
            return ["$", "$$"].randomElement()
        default:
            return nil
        }
    }
}