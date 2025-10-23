//
//  CountryManager.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 17/10/25.
//

import SwiftUI
import Combine

// Shared data model for the selected country
class CountryManager: ObservableObject {
    @Published var selectedCountry: CountryInfo?
    
    struct CountryInfo {
        let code: String
        let title: String
        let description: String
        let imageName: String
        let locationTag: String
    }
    
    // Available countries
    static let availableCountries: [CountryInfo] = [
        CountryInfo(
            code: "IT",
            title: "ITALY",
            description: "Italy is known for its crystal-clear waters, elegant villas, and serene landscapes, offering the perfect mix of beauty and relaxation.",
            imageName: "Italy",
            locationTag: "Rome, Italy"
        ),
        CountryInfo(
            code: "MX",
            title: "MEXICO",
            description: "Mexico blends vibrant culture, stunning beaches, and rich history from ancient ruins to lively cities offering unforgettable adventures.",
            imageName: "Mexico",
            locationTag: "Mexico City, Mexico"
        )
    ]
    
    func selectCountry(_ country: CountryInfo) {
        selectedCountry = country
    }
}
