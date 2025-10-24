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
        
        // Simulate API delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let details = generatePlaceDetails(for: place)
        
        await MainActor.run {
            self.placeDetails = details
            self.isLoading = false
        }
    }
    
    private func generatePlaceDetails(for place: MKMapItem) -> PlaceDetails {
        let name = place.name ?? "Unknown Place"
        let category = place.pointOfInterestCategory?.rawValue.replacingOccurrences(of: "MKPOICategory", with: "") ?? "Place"
        
        // Generate contextual descriptions based on category and name
        let description = generateDescription(name: name, category: category)
        
        // Generate relevant images using placeholder services that return real photos
        let imageUrls = generateImageUrls(name: name, category: category)
        
        // Generate realistic ratings
        let rating = Double.random(in: 3.8...4.8)
        let reviewCount = Int.random(in: 50...2500)
        
        return PlaceDetails(
            name: name,
            description: description,
            imageUrls: imageUrls,
            rating: rating,
            reviewCount: reviewCount,
            priceLevel: generatePriceLevel(category: category),
            website: place.url?.absoluteString,
            phoneNumber: place.phoneNumber
        )
    }
    
    private func generateDescription(name: String, category: String) -> String {
        switch category.lowercased() {
        case let c where c.contains("restaurant") || c.contains("food"):
            return "Experience authentic local cuisine in a welcoming atmosphere. This popular dining destination offers a carefully crafted menu featuring fresh, high-quality ingredients and exceptional service that keeps guests returning."
            
        case let c where c.contains("museum") || c.contains("gallery"):
            return "Discover fascinating exhibits and cultural treasures that tell the story of this remarkable place. With carefully curated collections and engaging displays, visitors can explore history, art, and culture in an inspiring environment."
            
        case let c where c.contains("park") || c.contains("garden"):
            return "Escape to this beautiful natural space perfect for relaxation and recreation. Whether you're looking for a peaceful walk, family activities, or simply a moment to connect with nature, this scenic location offers something for everyone."
            
        case let c where c.contains("shop") || c.contains("store"):
            return "Browse unique items and discover local treasures at this popular shopping destination. Known for quality products and friendly service, it's a favorite spot for both locals and visitors seeking authentic finds."
            
        case let c where c.contains("hotel") || c.contains("lodging"):
            return "Comfortable accommodations with excellent amenities and convenient location. Guests enjoy modern facilities, attentive service, and easy access to local attractions, making it an ideal choice for travelers."
            
        case let c where c.contains("church") || c.contains("temple") || c.contains("religious"):
            return "A place of worship and spiritual significance featuring beautiful architecture and peaceful surroundings. Visitors are welcome to appreciate the cultural and historical importance of this sacred space."
            
        case let c where c.contains("theater") || c.contains("entertainment"):
            return "Experience world-class entertainment and cultural performances in this acclaimed venue. With excellent acoustics and intimate atmosphere, it hosts a diverse range of shows that delight audiences year-round."
            
        case let c where c.contains("hospital") || c.contains("medical"):
            return "Comprehensive healthcare facility providing quality medical services to the community. With experienced professionals and modern equipment, patients receive excellent care in a comfortable environment."
            
        case let c where c.contains("school") || c.contains("university") || c.contains("education"):
            return "Distinguished educational institution committed to academic excellence and student success. With dedicated faculty and comprehensive programs, it provides quality education and valuable learning experiences."
            
        case let c where c.contains("bank") || c.contains("atm"):
            return "Full-service financial institution offering convenient banking solutions. With professional staff and comprehensive services, customers can manage their financial needs efficiently and securely."
            
        default:
            return "A notable local destination that attracts visitors with its unique character and offerings. Known for its welcoming atmosphere and quality service, it's a popular choice among both residents and tourists exploring the area."
        }
    }
    
    private func generateImageUrls(name: String, category: String) -> [String] {
        // Using Unsplash API for high-quality, real photos
        let baseUrl = "https://source.unsplash.com/400x300/?"
        
        var searchTerms: [String] = []
        
        switch category.lowercased() {
        case let c where c.contains("restaurant") || c.contains("food"):
            searchTerms = ["restaurant,food", "cuisine,dining", "food,delicious"]
            
        case let c where c.contains("museum"):
            searchTerms = ["museum,art", "gallery,culture", "exhibition,history"]
            
        case let c where c.contains("park") || c.contains("garden"):
            searchTerms = ["park,nature", "garden,landscape", "trees,peaceful"]
            
        case let c where c.contains("shop") || c.contains("store"):
            searchTerms = ["shop,retail", "store,shopping", "boutique,fashion"]
            
        case let c where c.contains("hotel"):
            searchTerms = ["hotel,luxury", "accommodation,comfortable", "hospitality,room"]
            
        case let c where c.contains("church") || c.contains("temple"):
            searchTerms = ["church,architecture", "temple,spiritual", "religious,building"]
            
        case let c where c.contains("theater"):
            searchTerms = ["theater,performance", "stage,entertainment", "concert,music"]
            
        case let c where c.contains("bank"):
            searchTerms = ["bank,modern", "finance,building", "architecture,business"]
            
        case let c where c.contains("hospital"):
            searchTerms = ["hospital,medical", "healthcare,modern", "clinic,clean"]
            
        case let c where c.contains("gas") || c.contains("fuel"):
            searchTerms = ["gas,station", "fuel,travel", "car,service"]
            
        case let c where c.contains("library"):
            searchTerms = ["library,books", "reading,knowledge", "study,quiet"]
            
        default:
            searchTerms = ["architecture,building", "city,urban", "travel,destination"]
        }
        
        // Return 2-4 different images
        let imageCount = Int.random(in: 2...4)
        return Array(0..<imageCount).map { index in
            let term = searchTerms[index % searchTerms.count]
            return "\(baseUrl)\(term)&sig=\(abs(name.hashValue + index))"
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