//
//  ContentView.swift
//  Travelo
//
//  Created by Dawar Hasnain on 10/10/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showCountrySelection: Bool = false
    @State private var showCountrySelectionFromHome: Bool = false
    @StateObject private var countryManager = CountryManager()
    @StateObject private var stepStateManager = StepStateManager()
    @StateObject private var profileManager = UserProfileManager()
    
    // Computed property to determine if we should show onboarding
    private var shouldShowOnboarding: Bool {
        !countryManager.hasCompletedOnboarding
    }
    
    var body: some View {
        ZStack {
            if showCountrySelectionFromHome {
                // Country selection from HomeView (going back to change country)
                CountrySelectionView {
                    // When location is chosen, return to home
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.2)) {
                        showCountrySelectionFromHome = false
                    }
                }
                .environmentObject(countryManager)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),  // Slides in from left (backward navigation)
                    removal: .move(edge: .leading).combined(with: .opacity)     // Slides out to left (forward navigation)
                ))
                .zIndex(2)
            } else if shouldShowOnboarding && !showCountrySelection {
                // Start screen shown for new users
                StartView {
                    // Show country selection when START is tapped
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.1)) {
                        showCountrySelection = true
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else if showCountrySelection && shouldShowOnboarding {
                // Country selection view for new users
                CountrySelectionView {
                    // When location is chosen, go to main app
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.2)) {
                        selectedTab = .home
                        showCountrySelection = false
                    }
                }
                .environmentObject(countryManager)
                .transition(.opacity) // Simple fade out, no sliding
            } else {
                TabView(selection: $selectedTab) {
                    HomeView {
                        // Callback when user taps on country name to change country
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.2)) {
                            showCountrySelectionFromHome = true
                        }
                    }
                    .tabItem {
                        Image(systemName: Tab.home.icon)
                        Text(Tab.home.rawValue)
                    }
                    .tag(Tab.home)
                    .onAppear {
                        // Request location permission when user first reaches HomeView
                        if !countryManager.locationService.isLocationAvailable &&
                           countryManager.locationService.authorizationStatus == .notDetermined {
                            countryManager.requestLocationOnFirstLaunch()
                        }
                    }
                    
                    StressReliefView()
                        .tabItem {
                            Image(systemName: Tab.map.icon)
                            Text(Tab.map.rawValue)
                        }
                        .tag(Tab.map)
                    
                    GuideView()
                        .tabItem {
                            Image(systemName: Tab.guide.icon)
                            Text(Tab.guide.rawValue)
                        }
                        .tag(Tab.guide)
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: Tab.profile.icon)
                            Text(Tab.profile.rawValue)
                        }
                        .tag(Tab.profile)
                }
                .accentColor(Color("Primary"))
                .environmentObject(countryManager)
                .environmentObject(stepStateManager)
                .environmentObject(profileManager)
                .transition(.asymmetric(
                    insertion: .opacity, // Simple fade in for main app
                    removal: .opacity
                ))
                .animation(.easeInOut(duration: 0.45), value: shouldShowOnboarding)
                .onChange(of: countryManager.selectedCountry?.code) { newCode in
                    if let code = newCode {
                        stepStateManager.updateCountry(code, templateVersion: 1)
                    }
                }
            }
        }
        .onAppear {
            // Initialize step state manager with the saved country if available
            if let selectedCountry = countryManager.selectedCountry {
                stepStateManager.updateCountry(selectedCountry.code, templateVersion: 1)
            }
        }
    }
}

#Preview {
    ContentView()
}
