//
//  PopularPlacesMapView.swift
//  Travelo
//
//  Created by Dawar Hasnain on 10/24/25.
//

import SwiftUI
import MapKit
import Combine

// Make MKMapItem conform to Identifiable
extension MKMapItem: Identifiable {
    public var id: String {
        return name ?? UUID().uuidString
    }
}

struct PopularPlacesMapView: View {
    @StateObject private var placesService = LocationBasedPlacesService()
    @EnvironmentObject var countryManager: CountryManager
    @State private var selectedPlace: MKMapItem?
    @State private var showingPlaceDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Text("Popular Places Nearby")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    // Force refresh with haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        refreshPlaces()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("Primary"))
                        .rotationEffect(.degrees(placesService.isLoading ? 360 : 0))
                        .animation(
                            placesService.isLoading ? 
                            .linear(duration: 1).repeatForever(autoreverses: false) : 
                            .default, 
                            value: placesService.isLoading
                        )
                }
                .disabled(placesService.isLoading)
            }
            .padding(.horizontal, 20)
            
            // Map with real places
            Map(coordinateRegion: $placesService.region, 
                interactionModes: [.zoom, .pan], 
                annotationItems: placesService.nearbyPlaces) { place in
                MapAnnotation(coordinate: place.placemark.coordinate) {
                    RealPlaceMarker(place: place) {
                        selectedPlace = place
                        showingPlaceDetail = true
                    }
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                // Loading overlay - properly contained within map bounds
                Group {
                    if placesService.isLoading {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.6))
                            .overlay {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.2)
                                    
                                    Text("Finding nearby places...")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black.opacity(0.3))
                                        .blur(radius: 0.5)
                                )
                            }
                            .transition(.opacity)
                    }
                }
            )
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showingPlaceDetail) {
            if let place = selectedPlace {
                RealPlaceDetailSheet(place: place)
            }
        }
        .onAppear {
            // Auto-start loading when view appears
            if placesService.nearbyPlaces.isEmpty && !placesService.isLoading {
                initializeLocation()
            }
        }
        .onChange(of: countryManager.selectedCountry?.code) { _ in
            // Reload when country changes
            initializeLocation()
        }
        .onReceive(countryManager.locationService.$currentLocation) { location in
            // Reload when user's location updates
            if let location = location, placesService.nearbyPlaces.isEmpty {
                placesService.updateRegion(for: location.coordinate)
                placesService.searchNearbyPlaces(around: location.coordinate)
            }
        }
    }
    
    private func initializeLocation() {
        // Always start with loading state for better UX
        if !placesService.isLoading {
            placesService.isLoading = true
        }
        
        // First try to get user's actual location
        if countryManager.locationService.isLocationAvailable,
           let userLocation = countryManager.locationService.currentLocation {
            placesService.updateRegion(for: userLocation.coordinate)
            placesService.searchNearbyPlaces(around: userLocation.coordinate)
        } else {
            // Fallback to selected country's main city
            let coordinate = getCountryCoordinate()
            placesService.updateRegion(for: coordinate)
            placesService.searchNearbyPlaces(around: coordinate)
            
            // Also try to request location permission for next time
            placesService.requestLocationPermission()
        }
    }
    
    private func refreshPlaces() {
        // Clear current places first for immediate visual feedback
        if !placesService.isLoading {
            Task {
                await MainActor.run {
                    placesService.nearbyPlaces = []
                }
                
                // Small delay to show the loading state
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                
                if let userLocation = placesService.userLocation {
                    placesService.searchNearbyPlaces(around: userLocation)
                } else {
                    initializeLocation()
                }
            }
        }
    }
    
    private func getCountryCoordinate() -> CLLocationCoordinate2D {
        guard let countryCode = countryManager.selectedCountry?.code else {
            return CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco fallback
        }
        
        switch countryCode {
        case "IT":
            return CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964) // Rome
        case "MX":
            return CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332) // Mexico City
        default:
            return CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Default
        }
    }
}

// MARK: - Real Place Marker
struct RealPlaceMarker: View {
    let place: MKMapItem
    let onTap: () -> Void
    
    private var categoryIcon: String {
        guard let category = place.pointOfInterestCategory else { 
            print("❌ No category for place: \(place.name ?? "Unknown")")
            return "location.fill" 
        }
        
        let categoryString = category.rawValue
        print("🏷️ Place: \(place.name ?? "Unknown") - Category: \(categoryString)")
        
        // Use only basic SF Symbols that definitely exist
        let icon: String
        switch categoryString {
        // Food & Dining - using basic symbols
        case "MKPOICategoryRestaurant":
            icon = "fork.knife"
            print("🍽️ Restaurant icon: fork.knife")
        case "MKPOICategoryCafe":
            icon = "cup.and.saucer.fill"
            print("☕ Cafe icon: cup.and.saucer.fill")
        case "MKPOICategoryBakery":
            icon = "birthday.cake.fill"
            print("🎂 Bakery icon: birthday.cake.fill")
            
        // Shopping & Services - using very basic symbols
        case "MKPOICategoryStore":
            icon = "bag.fill"
            print("🛍️ Store icon: bag.fill")
        case "MKPOICategoryDepartmentStore":
            icon = "building.2.fill"
            print("🏪 Department Store icon: building.2.fill")
        case "MKPOICategoryGasStation":
            icon = "fuelpump.fill"
            print("⛽ Gas Station icon: fuelpump.fill")
        case "MKPOICategoryBank":
            icon = "dollarsign.circle.fill"
            print("🏦 Bank icon: dollarsign.circle.fill")
        case "MKPOICategoryATM":
            icon = "creditcard.fill"
            print("💳 ATM icon: creditcard.fill")
        case "MKPOICategoryPharmacy":
            icon = "cross.case.fill"
            print("💊 Pharmacy icon: cross.case.fill")
            
        // Culture & Education
        case "MKPOICategoryMuseum":
            icon = "building.columns.fill"
            print("🏛️ Museum icon: building.columns.fill")
        case "MKPOICategoryLibrary":
            icon = "book.fill"
            print("📚 Library icon: book.fill")
        case "MKPOICategorySchool", "MKPOICategoryUniversity":
            icon = "graduationcap.fill"
            print("🎓 School icon: graduationcap.fill")
            
        // Recreation & Nature
        case "MKPOICategoryPark":
            icon = "tree.fill"
            print("🌳 Park icon: tree.fill")
        case "MKPOICategoryAmusementPark":
            icon = "gamecontroller.fill"
            print("🎮 Amusement Park icon: gamecontroller.fill")
        case "MKPOICategoryZoo":
            icon = "pawprint.fill"
            print("🐾 Zoo icon: pawprint.fill")
        case "MKPOICategoryBeach":
            icon = "sun.max.fill"
            print("🏖️ Beach icon: sun.max.fill")
            
        // Hospitality
        case "MKPOICategoryHotel", "MKPOICategoryLodging":
            icon = "bed.double.fill"
            print("🏨 Hotel icon: bed.double.fill")
            
        // Medical & Health
        case "MKPOICategoryHospital":
            icon = "cross.fill"
            print("🏥 Hospital icon: cross.fill")
        case "MKPOICategoryFitnessCenter":
            icon = "figure.run"
            print("💪 Fitness icon: figure.run")
            
        // Transportation
        case "MKPOICategoryAirport":
            icon = "airplane"
            print("✈️ Airport icon: airplane")
        case "MKPOICategoryCarRental":
            icon = "car.fill"
            print("🚗 Car Rental icon: car.fill")
        case "MKPOICategoryEVCharger":
            icon = "bolt.fill"
            print("⚡ EV Charger icon: bolt.fill")
            
        // Entertainment
        case "MKPOICategoryTheater":
            icon = "theatermasks.fill"
            print("🎭 Theater icon: theatermasks.fill")
        case "MKPOICategoryMovieTheater":
            icon = "tv.fill"
            print("📺 Movie Theater icon: tv.fill")
        case "MKPOICategoryNightlife":
            icon = "music.note"
            print("🎵 Nightlife icon: music.note")
            
        // Religious & Community
        case "MKPOICategoryPlaceOfWorship":
            icon = "building.fill"
            print("⛪ Worship icon: building.fill")
        case "MKPOICategoryPublicTransport":
            icon = "bus.fill"
            print("🚌 Transit icon: bus.fill")
            
        // Default case with detailed logging
        default:
            print("❓ Unknown category: \(categoryString)")
            // Try to match common words in the category name
            let lowerCategory = categoryString.lowercased()
            if lowerCategory.contains("restaurant") || lowerCategory.contains("food") {
                icon = "fork.knife"
                print("🍽️ Fallback restaurant icon")
            } else if lowerCategory.contains("store") || lowerCategory.contains("shop") {
                icon = "bag.fill"
                print("🛍️ Fallback store icon")
            } else if lowerCategory.contains("gas") || lowerCategory.contains("fuel") {
                icon = "fuelpump.fill"
                print("⛽ Fallback gas icon")
            } else if lowerCategory.contains("hotel") {
                icon = "bed.double.fill"
                print("🏨 Fallback hotel icon")
            } else if lowerCategory.contains("park") {
                icon = "tree.fill"
                print("🌳 Fallback park icon")
            } else if lowerCategory.contains("hospital") || lowerCategory.contains("medical") {
                icon = "cross.fill"
                print("🏥 Fallback medical icon")
            } else if lowerCategory.contains("bank") {
                icon = "dollarsign.circle.fill"
                print("🏦 Fallback bank icon")
            } else if lowerCategory.contains("museum") {
                icon = "building.columns.fill"
                print("🏛️ Fallback museum icon")
            } else if lowerCategory.contains("airport") {
                icon = "airplane"
                print("✈️ Fallback airport icon")
            } else {
                icon = "location.fill"
                print("📍 Using default location icon for: \(categoryString)")
            }
        }
        
        print("✅ Final icon for \(place.name ?? "Unknown"): \(icon)")
        return icon
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(Color("Primary"))
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Real Place Detail Sheet
struct RealPlaceDetailSheet: View {
    let place: MKMapItem
    @Environment(\.dismiss) private var dismiss
    @StateObject private var detailsService = PlaceDetailsService()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Visual header with place info
                    VStack(spacing: 16) {
                        // Large icon representing the place type
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color("Primary").opacity(0.2),
                                            Color("Primary").opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: getIconForCategory(place.pointOfInterestCategory))
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(Color("Primary"))
                        }
                        
                        // Place type indicator
                        VStack(spacing: 8) {
                            if let category = place.pointOfInterestCategory {
                                Text(formatCategoryName(category))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color("Primary"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color("Primary").opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(.systemGray6).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Place name, rating, and category
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(place.name ?? "Unknown Place")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                // Rating from API
                                if let details = detailsService.placeDetails, let rating = details.rating {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                        Text(String(format: "%.1f", rating))
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        if let reviewCount = details.reviewCount {
                                            Text("(\(reviewCount))")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                if let category = place.pointOfInterestCategory {
                                    let categoryName = formatCategoryName(category)
                                    Text(categoryName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Color("Primary").opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                
                                // Price level
                                if let details = detailsService.placeDetails, let priceLevel = details.priceLevel {
                                    Text(priceLevel)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        
                        // Address
                        if let address = place.placemark.formattedAddress {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "location")
                                    .font(.caption)
                                    .foregroundColor(Color("Primary"))
                                    .padding(.top, 2)
                                
                                Text(address)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Phone number
                        if let phoneNumber = place.phoneNumber {
                            HStack(spacing: 8) {
                                Image(systemName: "phone")
                                    .font(.caption)
                                    .foregroundColor(Color("Primary"))
                                
                                Text(phoneNumber)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        // Website
                        if let url = place.url {
                            HStack(spacing: 8) {
                                Image(systemName: "globe")
                                    .font(.caption)
                                    .foregroundColor(Color("Primary"))
                                
                                Text(url.absoluteString)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        UIApplication.shared.open(url)
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            place.openInMaps()
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Open in Maps")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("Primary"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button(action: {
                            sharePlace(place)
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Place")
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
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Place Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await detailsService.fetchPlaceDetails(for: place)
        }
    }
    
    // Format category name to be more readable
    private func formatCategoryName(_ category: MKPointOfInterestCategory) -> String {
        let rawValue = category.rawValue
        
        // Remove MKPOICategory prefix and format
        let cleanName = rawValue.replacingOccurrences(of: "MKPOICategory", with: "")
        
        // Convert camelCase to readable format
        let result = cleanName.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
        
        return result.capitalized
    }
    
    // Get appropriate icon for place category
    private func getIconForCategory(_ category: MKPointOfInterestCategory?) -> String {
        guard let category = category else { return "building.2" }
        
        let categoryString = category.rawValue.replacingOccurrences(of: "MKPOICategory", with: "").lowercased()
        
        switch categoryString {
        case let c where c.contains("restaurant") || c.contains("food"):
            return "fork.knife"
        case let c where c.contains("museum") || c.contains("gallery"):
            return "building.columns"
        case let c where c.contains("park") || c.contains("garden"):
            return "leaf"
        case let c where c.contains("shop") || c.contains("store") || c.contains("retail"):
            return "bag"
        case let c where c.contains("hotel") || c.contains("lodging"):
            return "bed.double"
        case let c where c.contains("hospital") || c.contains("medical"):
            return "cross"
        case let c where c.contains("school") || c.contains("university"):
            return "graduationcap"
        case let c where c.contains("bank") || c.contains("atm"):
            return "building.columns"
        case let c where c.contains("gas") || c.contains("fuel"):
            return "fuelpump"
        case let c where c.contains("library"):
            return "books.vertical"
        case let c where c.contains("church") || c.contains("religious"):
            return "building"
        case let c where c.contains("theater") || c.contains("entertainment"):
            return "theatermasks"
        case let c where c.contains("airport"):
            return "airplane"
        case let c where c.contains("subway") || c.contains("transit"):
            return "tram"
        default:
            return "building.2"
        }
    }
    
    // Share place functionality
    private func sharePlace(_ place: MKMapItem) {
        let placeName = place.name ?? "Interesting Place"
        let coordinate = place.placemark.coordinate
        let address = place.placemark.formattedAddress ?? "Location"
        
        var shareItems: [Any] = []
        
        // Add place information
        let shareText = """
        📍 \(placeName)
        
        📭 \(address)
        
        🗺️ Coordinates: \(coordinate.latitude), \(coordinate.longitude)
        
        Found via Travelo
        """
        
        shareItems.append(shareText)
        
        // Add Apple Maps URL if possible
        if let url = place.url {
            shareItems.append(url)
        } else {
            // Create Apple Maps URL
            let mapsURL = "https://maps.apple.com/?q=\(coordinate.latitude),\(coordinate.longitude)"
            if let url = URL(string: mapsURL) {
                shareItems.append(url)
            }
        }
        
        // Present share sheet
        let activityController = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        
        // Configure for iPad
        if let popover = activityController.popoverPresentationController {
            popover.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            // Find the topmost view controller
            var topController = rootViewController
            while let presented = topController.presentedViewController {
                topController = presented
            }
            
            topController.present(activityController, animated: true)
        }
    }
}

// MARK: - Extensions
extension CLPlacemark {
    var formattedAddress: String? {
        guard let name = name else { return nil }
        
        var addressComponents: [String] = [name]
        
        if let thoroughfare = thoroughfare {
            addressComponents.append(thoroughfare)
        }
        
        if let locality = locality {
            addressComponents.append(locality)
        }
        
        if let country = country {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: ", ")
    }
}

#Preview {
    PopularPlacesMapView()
        .environmentObject(CountryManager())
}