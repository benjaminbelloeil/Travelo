//
//  UserProfileManager.swift
//  Travelo
//
//  Created by Dawar Hasnain on 10/24/25.
//

import SwiftUI
import Combine

// User profile data model
struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var dateOfBirth: Date?
    var profileImageData: Data?
    var emergencyContactName: String
    var emergencyContactPhone: String
    var preferredLanguage: String
    var notificationsEnabled: Bool
    var locationSharingEnabled: Bool
    var createdDate: Date
    var lastUpdated: Date
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.email = ""
        self.phoneNumber = ""
        self.dateOfBirth = nil
        self.profileImageData = nil
        self.emergencyContactName = ""
        self.emergencyContactPhone = ""
        self.preferredLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        self.notificationsEnabled = true
        self.locationSharingEnabled = false
        self.createdDate = Date()
        self.lastUpdated = Date()
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return firstInitial + lastInitial
    }
    
    var age: Int? {
        guard let dateOfBirth = dateOfBirth else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year
    }
}

// Profile manager for local storage and data management
class UserProfileManager: ObservableObject {
    @Published var userProfile: UserProfile {
        didSet {
            saveProfile()
        }
    }
    
    @Published var isEditing: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let profileKey = "userProfile"
    
    init() {
        self.userProfile = UserProfileManager.loadProfile()
    }
    
    // MARK: - Profile Management
    
    func updateProfile(_ profile: UserProfile) {
        var updatedProfile = profile
        updatedProfile.lastUpdated = Date()
        self.userProfile = updatedProfile
    }
    
    func updateProfileImage(_ imageData: Data?) {
        userProfile.profileImageData = imageData
        userProfile.lastUpdated = Date()
    }
    
    func clearProfile() {
        userDefaults.removeObject(forKey: profileKey)
        userProfile = UserProfile()
    }
    
    var isProfileComplete: Bool {
        return !userProfile.firstName.isEmpty && !userProfile.lastName.isEmpty
    }
    
    var profileCompletionPercentage: Double {
        var completedFields = 0
        let totalFields = 8
        
        if !userProfile.firstName.isEmpty { completedFields += 1 }
        if !userProfile.lastName.isEmpty { completedFields += 1 }
        if !userProfile.email.isEmpty { completedFields += 1 }
        if !userProfile.phoneNumber.isEmpty { completedFields += 1 }
        if userProfile.dateOfBirth != nil { completedFields += 1 }
        if userProfile.profileImageData != nil { completedFields += 1 }
        if !userProfile.emergencyContactName.isEmpty { completedFields += 1 }
        if !userProfile.emergencyContactPhone.isEmpty { completedFields += 1 }
        
        return Double(completedFields) / Double(totalFields)
    }
    
    // MARK: - Private Methods
    
    private func saveProfile() {
        do {
            let encoded = try JSONEncoder().encode(userProfile)
            userDefaults.set(encoded, forKey: profileKey)
        } catch {
            print("Failed to save user profile: \(error)")
        }
    }
    
    private static func loadProfile() -> UserProfile {
        guard let data = UserDefaults.standard.data(forKey: "userProfile"),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return UserProfile()
        }
        return profile
    }
}