//
//  ProfileComponents.swift
//  Travelo
//
//  Created by Dawar Hasnain on 10/24/25.
//

import SwiftUI

// MARK: - Profile Image View
struct ProfileImageView: View {
    let imageData: Data?
    let initials: String
    let size: CGFloat
    
    var body: some View {
        ZStack {
            if let imageData = imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                // Default avatar with initials
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("Primary").opacity(0.8),
                                Color("Primary")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay {
                        if !initials.isEmpty {
                            Text(initials)
                                .font(.system(size: size * 0.4, weight: .semibold))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: size * 0.4))
                                .foregroundColor(.white)
                        }
                    }
            }
            
            // Camera overlay
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: "camera.fill")
                        .font(.system(size: size * 0.2))
                        .foregroundColor(.white)
                }
                .opacity(imageData == nil ? 0 : 0.8)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Profile Completion Card
struct ProfileCompletionCard: View {
    let completionPercentage: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Complete Your Profile")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(Int(completionPercentage * 100))% Complete")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: completionPercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("Primary")))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("Primary"))
            }
            .padding()
            .background(Color("Primary").opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile Section Card
struct ProfileSectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color("Primary"))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            content()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Content Views
struct PersonalInfoContent: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoRow(
                label: "Full Name",
                value: profile.fullName.isEmpty ? "Not set" : profile.fullName,
                isEmpty: profile.fullName.isEmpty
            )
            
            if let dateOfBirth = profile.dateOfBirth {
                InfoRow(
                    label: "Date of Birth",
                    value: dateOfBirth.formatted(date: .abbreviated, time: .omitted)
                )
                
                if let age = profile.age {
                    InfoRow(
                        label: "Age",
                        value: "\(age) years old"
                    )
                }
            } else {
                InfoRow(
                    label: "Date of Birth",
                    value: "Not set",
                    isEmpty: true
                )
            }
        }
    }
}

struct ContactInfoContent: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoRow(
                label: "Email",
                value: profile.email.isEmpty ? "Not set" : profile.email,
                isEmpty: profile.email.isEmpty
            )
            
            InfoRow(
                label: "Phone",
                value: profile.phoneNumber.isEmpty ? "Not set" : profile.phoneNumber,
                isEmpty: profile.phoneNumber.isEmpty
            )
            
            InfoRow(
                label: "Language",
                value: Locale.current.localizedString(forLanguageCode: profile.preferredLanguage) ?? profile.preferredLanguage
            )
        }
    }
}

struct EmergencyContactContent: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoRow(
                label: "Contact Name",
                value: profile.emergencyContactName.isEmpty ? "Not set" : profile.emergencyContactName,
                isEmpty: profile.emergencyContactName.isEmpty
            )
            
            InfoRow(
                label: "Contact Phone",
                value: profile.emergencyContactPhone.isEmpty ? "Not set" : profile.emergencyContactPhone,
                isEmpty: profile.emergencyContactPhone.isEmpty
            )
        }
    }
}

struct SettingsContent: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Notifications")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: profile.notificationsEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(profile.notificationsEnabled ? .green : .secondary)
            }
            
            HStack {
                Text("Location Sharing")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: profile.locationSharingEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(profile.locationSharingEnabled ? .green : .secondary)
            }
            
            InfoRow(
                label: "Member Since",
                value: profile.createdDate.formatted(date: .abbreviated, time: .omitted)
            )
        }
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let label: String
    let value: String
    let isEmpty: Bool
    
    init(label: String, value: String, isEmpty: Bool = false) {
        self.label = label
        self.value = value
        self.isEmpty = isEmpty
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(isEmpty ? .secondary : .primary)
                .fontWeight(isEmpty ? .regular : .medium)
        }
    }
}