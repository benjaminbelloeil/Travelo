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
            Map(coordinateRegion: $placesService.region, annotationItems: placesService.nearbyPlaces) { place in
                MapAnnotation(coordinate: place.placemark.coordinate) {
                    RealPlaceMarker(place: place) {
                        selectedPlace = place
                        showingPlaceDetail = true
                    }
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .overlay(
                // Loading overlay
                Group {
                    if placesService.isLoading {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Primary").opacity(0.2))
                            .overlay {
                                VStack(spacing: 8) {
                                    ProgressView()
                                        .tint(Color("Primary"))
                                    Text("Finding nearby places...")
                                        .font(.caption)
                                        .foregroundColor(Color("Primary"))
                                        .fontWeight(.medium)
                                }
                            }
                    }
                }
            )
        }
        .sheet(isPresented: $showingPlaceDetail) {
            if let place = selectedPlace {
                RealPlaceDetailSheet(place: place)
            }
        }
        .onAppear {
            initializeLocation()
        }
        .onChange(of: countryManager.selectedCountry?.code) { _ in
            initializeLocation()
        }
    }
    
    private func initializeLocation() {
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
            
            // Also try to request location permission
            placesService.requestLocationPermission()
        }
    }
    
    private func refreshPlaces() {
        if let userLocation = placesService.userLocation {
            placesService.searchNearbyPlaces(around: userLocation)
        } else {
            initializeLocation()
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
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(Color("Primary"))
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: "mappin")
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
                    // Photo section with real images
                    if let details = detailsService.placeDetails, !details.imageUrls.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(details.imageUrls.enumerated()), id: \.offset) { index, imageUrl in
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 250, height: 180)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("Primary").opacity(0.1))
                                            .frame(width: 250, height: 180)
                                            .overlay {
                                                ProgressView()
                                                    .tint(Color("Primary"))
                                            }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    } else if detailsService.isLoading {
                        // Loading placeholder
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Primary").opacity(0.1))
                            .frame(height: 180)
                            .overlay {
                                VStack(spacing: 8) {
                                    ProgressView()
                                        .tint(Color("Primary"))
                                    Text("Loading photos...")
                                        .font(.caption)
                                        .foregroundColor(Color("Primary"))
                                }
                            }
                            .padding(.horizontal, 20)
                    }
                    
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
                        
                        // Description from API
                        if let details = detailsService.placeDetails {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(details.description)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .lineSpacing(2)
                            }
                        } else if detailsService.isLoading {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                // Loading placeholder for description
                                VStack(alignment: .leading, spacing: 4) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 12)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 12)
                                        .frame(width: UIScreen.main.bounds.width * 0.7)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 12)
                                        .frame(width: UIScreen.main.bounds.width * 0.8)
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
                            // Share functionality
                            if let name = place.name {
                                let activityVC = UIActivityViewController(
                                    activityItems: ["\(name) - Found via Travelo"],
                                    applicationActivities: nil
                                )
                                
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootViewController = windowScene.windows.first?.rootViewController {
                                    rootViewController.present(activityVC, animated: true)
                                }
                            }
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