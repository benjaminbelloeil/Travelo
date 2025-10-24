//
//  ProfileView.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 15/10/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var profileManager = UserProfileManager()
    @EnvironmentObject var countryManager: CountryManager
    @State private var showingImagePicker = false
    @State private var showingEditProfile = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header Section
                    VStack(spacing: 16) {
                        // Profile Image
                        ProfileImageView(
                            imageData: profileManager.userProfile.profileImageData,
                            initials: profileManager.userProfile.initials,
                            size: 120
                        )
                        .onTapGesture {
                            showingImagePicker = true
                        }
                        
                        // Name and Location
                        VStack(spacing: 8) {
                            if profileManager.isProfileComplete {
                                Text(profileManager.userProfile.fullName)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            } else {
                                Text("Complete Your Profile")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(countryManager.currentLocationTag)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Profile Completion Progress
                        if !profileManager.isProfileComplete {
                            ProfileCompletionCard(
                                completionPercentage: profileManager.profileCompletionPercentage
                            ) {
                                showingEditProfile = true
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    // Profile Information Cards
                    LazyVStack(spacing: 16) {
                        // Personal Information
                        ProfileSectionCard(
                            title: "Personal Information",
                            icon: "person.fill",
                            content: {
                                PersonalInfoContent(profile: profileManager.userProfile)
                            }
                        )
                        
                        // Contact Information
                        ProfileSectionCard(
                            title: "Contact Information",
                            icon: "phone.fill",
                            content: {
                                ContactInfoContent(profile: profileManager.userProfile)
                            }
                        )
                        
                        // Emergency Contact
                        ProfileSectionCard(
                            title: "Emergency Contact",
                            icon: "cross.case.fill",
                            content: {
                                EmergencyContactContent(profile: profileManager.userProfile)
                            }
                        )
                        
                        // Settings
                        ProfileSectionCard(
                            title: "Settings",
                            icon: "gear.fill",
                            content: {
                                SettingsContent(profile: profileManager.userProfile)
                            }
                        )
                    }
                    
                    // Edit Profile Button
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                            Text("Edit Profile")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color("Primary"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("Primary"), lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            profileManager.updateProfileImage(data)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(profileManager: profileManager)
            }
        }
        .environmentObject(profileManager)
    }
}

#Preview {
    ProfileView()
        .environmentObject(CountryManager())
}
