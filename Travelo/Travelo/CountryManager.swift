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
    @Published var selectedCountry: CountryInfo? {
        didSet {
            saveSelectedCountry()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let selectedCountryKey = "selectedCountryCode"
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    struct CountryInfo: Codable {
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
    
    init() {
        loadSelectedCountry()
    }
    
    func selectCountry(_ country: CountryInfo) {
        selectedCountry = country
        markOnboardingAsComplete()
    }
    
    var hasCompletedOnboarding: Bool {
        return userDefaults.bool(forKey: hasCompletedOnboardingKey) && selectedCountry != nil
    }
    
    private func markOnboardingAsComplete() {
        userDefaults.set(true, forKey: hasCompletedOnboardingKey)
    }
    
    private func saveSelectedCountry() {
        if let country = selectedCountry {
            userDefaults.set(country.code, forKey: selectedCountryKey)
        } else {
            userDefaults.removeObject(forKey: selectedCountryKey)
        }
    }
    
    private func loadSelectedCountry() {
        let savedCountryCode = userDefaults.string(forKey: selectedCountryKey)
        
        if let countryCode = savedCountryCode,
           let country = Self.availableCountries.first(where: { $0.code == countryCode }) {
            selectedCountry = country
        }
    }
    
    // For testing purposes or if user wants to reset the app
    func resetOnboarding() {
        userDefaults.removeObject(forKey: hasCompletedOnboardingKey)
        userDefaults.removeObject(forKey: selectedCountryKey)
        selectedCountry = nil
    }
}
