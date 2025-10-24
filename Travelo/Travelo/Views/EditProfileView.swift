//
//  EditProfileView.swift
//  Travelo
//
//  Created by Dawar Hasnain on 10/24/25.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var profileManager: UserProfileManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var countryManager: CountryManager
    
    @State private var editedProfile: UserProfile
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showDatePicker = false
    @State private var showingLocationAlert = false
    
    init(profileManager: UserProfileManager) {
        self.profileManager = profileManager
        self._editedProfile = State(initialValue: profileManager.userProfile)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Image Section
                Section {
                    HStack {
                        Spacer()
                        ProfileImageView(
                            imageData: editedProfile.profileImageData,
                            initials: editedProfile.initials,
                            size: 100,
                            showCameraOverlay: true
                        )
                        .onTapGesture {
                            showingImagePicker = true
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    HStack {
                        Spacer()
                        Button("Change Photo") {
                            showingImagePicker = true
                        }
                        .font(.subheadline)
                        Spacer()
                    }
                } header: {
                    Text("Profile Photo")
                }
                
                // Personal Information
                Section("Personal Information") {
                    TextField("First Name", text: $editedProfile.firstName)
                        .textContentType(.givenName)
                    
                    TextField("Last Name", text: $editedProfile.lastName)
                        .textContentType(.familyName)
                    
                    HStack {
                        Text("Date of Birth")
                        Spacer()
                        if let dateOfBirth = editedProfile.dateOfBirth {
                            Button(dateOfBirth.formatted(date: .abbreviated, time: .omitted)) {
                                showDatePicker = true
                            }
                            .foregroundColor(Color("Primary"))
                        } else {
                            Button("Set Date") {
                                showDatePicker = true
                            }
                            .foregroundColor(Color("Primary"))
                        }
                    }
                    .sheet(isPresented: $showDatePicker) {
                        ImprovedDatePickerSheet(selectedDate: Binding(
                            get: { editedProfile.dateOfBirth ?? Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date() },
                            set: { editedProfile.dateOfBirth = $0 }
                        ))
                    }
                }
                
                // Contact Information
                Section("Contact Information") {
                    TextField("Email", text: $editedProfile.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Phone Number", text: $editedProfile.phoneNumber)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                // Emergency Contact
                Section("Emergency Contact") {
                    TextField("Emergency Contact Name", text: $editedProfile.emergencyContactName)
                        .textContentType(.name)
                    
                    TextField("Emergency Contact Phone", text: $editedProfile.emergencyContactPhone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                // Location & Privacy
                Section("Location & Privacy") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Location")
                                .foregroundColor(.primary)
                            Text(countryManager.currentLocationTag)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Update") {
                            if countryManager.locationService.isLocationAvailable {
                                countryManager.locationService.requestLocationPermission()
                            } else {
                                showingLocationAlert = true
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(Color("Primary"))
                    }
                    
                    Toggle("Share Location for Emergency", isOn: $editedProfile.locationSharingEnabled)
                }
                
                // Settings
                Section("Settings") {
                    Toggle("Enable Notifications", isOn: $editedProfile.notificationsEnabled)
                    
                    HStack {
                        Text("Preferred Language")
                        Spacer()
                        Text(Locale.current.localizedString(forLanguageCode: editedProfile.preferredLanguage) ?? editedProfile.preferredLanguage)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        profileManager.updateProfile(editedProfile)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
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
                            editedProfile.profileImageData = data
                        }
                    }
                }
            }
            .alert("Location Access Required", isPresented: $showingLocationAlert) {
                Button("Settings", action: openLocationSettings)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable location access in Settings to update your current location.")
            }
        }
    }
    
    private func openLocationSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Improved Date Picker Sheet
struct ImprovedDatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
            }
            .navigationTitle("Date of Birth")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    EditProfileView(profileManager: UserProfileManager())
        .environmentObject(CountryManager())
}
