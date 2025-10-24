//
//  PopularPlace.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 10/24/25.
//

import Foundation
import CoreLocation
import MapKit

struct PopularPlace: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let category: PlaceCategory
    let imageUrl: String?
    let rating: Double
    let isOpenNow: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var mapItem: MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        return mapItem
    }
}

enum PlaceCategory: String, CaseIterable, Codable {
    case restaurant = "Restaurant"
    case tourist = "Tourist Attraction"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case cultural = "Cultural Site"
    case nature = "Nature"
    case hotel = "Hotel"
    case transport = "Transportation"
    
    var iconName: String {
        switch self {
        case .restaurant:
            return "fork.knife"
        case .tourist:
            return "camera.fill"
        case .shopping:
            return "bag.fill"
        case .entertainment:
            return "theatermasks.fill"
        case .cultural:
            return "building.columns.fill"
        case .nature:
            return "leaf.fill"
        case .hotel:
            return "bed.double.fill"
        case .transport:
            return "bus.fill"
        }
    }
    
    var color: String {
        switch self {
        case .restaurant:
            return "orange"
        case .tourist:
            return "blue"
        case .shopping:
            return "purple"
        case .entertainment:
            return "red"
        case .cultural:
            return "brown"
        case .nature:
            return "green"
        case .hotel:
            return "indigo"
        case .transport:
            return "gray"
        }
    }
}

// MARK: - Popular Places Data
extension PopularPlace {
    static func places(for countryCode: String) -> [PopularPlace] {
        switch countryCode {
        case "IT": // Italy
            return [
                PopularPlace(
                    name: "Colosseum",
                    description: "Ancient amphitheater and iconic symbol of Rome",
                    latitude: 41.8902,
                    longitude: 12.4922,
                    category: .cultural,
                    imageUrl: nil,
                    rating: 4.6,
                    isOpenNow: true
                ),
                PopularPlace(
                    name: "Vatican Museums",
                    description: "World's greatest art collection including Sistine Chapel",
                    latitude: 41.9066,
                    longitude: 12.4536,
                    category: .cultural,
                    imageUrl: nil,
                    rating: 4.5,
                    isOpenNow: true
                ),
                PopularPlace(
                    name: "Trevi Fountain",
                    description: "Famous baroque fountain, throw a coin for good luck",
                    latitude: 41.9009,
                    longitude: 12.4833,
                    category: .tourist,
                    imageUrl: nil,
                    rating: 4.4,
                    isOpenNow: true
                ),
                PopularPlace(
                    name: "Pantheon",
                    description: "Best preserved Roman building with magnificent dome",
                    latitude: 41.8986,
                    longitude: 12.4769,
                    category: .cultural,
                    imageUrl: nil,
                    rating: 4.5,
                    isOpenNow: true
                ),
                PopularPlace(
                    name: "Trastevere",
                    description: "Charming medieval neighborhood with cobblestone streets",
                    latitude: 41.8895,
                    longitude: 12.4692,
                    category: .entertainment,
                    imageUrl: nil,
                    rating: 4.3,
                    isOpenNow: true
                ),
                PopularPlace(
                    name: "Villa Borghese",
                    description: "Large landscape garden with museums and lake",
                    latitude: 41.9142,
                    longitude: 12.4922,
                    category: .nature,
                    imageUrl: nil,
                    rating: 4.4,
                    isOpenNow: true
                )
            ]
            
        case "MX": // Mexico
            return [
                PopularPlace(
                    name: "Zócalo",
                    description: "Historic main square and heart of Mexico City",
                    latitude: 19.4326,
                    longitude: -99.1332,
                    category: .cultural,
                    imageUrl: nil,
                    rating: 4.4,
                    isOpenNow: true
                ),
                PopularPlace(
                    name: "Frida Kahlo Museum",
                    description: "Casa Azul - Former home of iconic Mexican artist",
                    latitude: 19.3550,
                    longitude: -99.1626,
                    category: .cultural,
                    imageUrl: nil,
                    rating: 4.3,
                    isOpenNow: true
                ),
                PopularPlace(
                    name: "Chapultepec Park",
                    description: "Large urban park with castle and museums",
                    latitude: 19.4194,
                    longitude: -99.1820,
                    category: .nature,
                    imageUrl: nil,
                    rating: 4.5,
                    isOpenNow: true
                ),
                PopularPlace(
                    name: "Teotihuacán",
                    description: "Ancient Mesoamerican pyramids and archaeological site",
                    latitude: 19.6925,
                    longitude: -98.8438,
                    category: .cultural,
                    imageUrl: nil,
                    rating: 4.6,
                    isOpenNow: true
                ),
                PopularPlace(
                    name: "Xochimilco",
                    description: "UNESCO site famous for colorful trajinera boats",
                    latitude: 19.2647,
                    longitude: -99.1031,
                    category: .nature,
                    imageUrl: nil,
                    rating: 4.2,
                    isOpenNow: true
                ),
                PopularPlace(
                    name: "Coyoacán",
                    description: "Colonial neighborhood with markets and cafes",
                    latitude: 19.3467,
                    longitude: -99.1618,
                    category: .entertainment,
                    imageUrl: nil,
                    rating: 4.4,
                    isOpenNow: true
                )
            ]
            
        default:
            return []
        }
    }
}
