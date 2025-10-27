//
//  ContentView.swift
//  Travelo
//
//  Created by Dawar Hasnain on 10/10/25.
//

import SwiftUI
import CoreLocation
import Combine

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showCountrySelection: Bool = false
    @State private var showCountrySelectionFromHome: Bool = false
    @StateObject private var countryManager = CountryManager()
    @StateObject private var stepStateManager = StepStateManager()
    @StateObject private var profileManager = UserProfileManager()
    
    // Add a state to force UI refresh when needed
    @State private var refreshTrigger = false
    
    // State for onboarding flow
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedAppOnboarding")
    
    // Computed property to determine if we should show onboarding
    private var shouldShowOnboarding: Bool {
        !countryManager.hasCompletedOnboarding
    }
    
    // Computed property to determine if we should show app intro onboarding
    private var shouldShowAppOnboarding: Bool {
        !hasCompletedOnboarding
    }
    
    var body: some View {
        ZStack {
            // Show App Onboarding first (only for first-time users)
            if shouldShowAppOnboarding {
                ImprovedOnBoardingView {
                    // When onboarding is complete, move to country selection
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                        hasCompletedOnboarding = true
                        UserDefaults.standard.set(true, forKey: "hasCompletedAppOnboarding")
                        showCountrySelection = true
                    }
                }
                .transition(.opacity)
                .zIndex(10)
            }
            
            // Show TabView only when not in onboarding or country selection
            else if !shouldShowOnboarding && !showCountrySelection && !showCountrySelectionFromHome {
                TabView(selection: $selectedTab) {
                    HomeView()
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
                .environment(\.tabSelection, $selectedTab)
                .environment(\.showCountrySelection, {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.2)) {
                        showCountrySelectionFromHome = true
                    }
                })
                .onChange(of: countryManager.selectedCountry?.code) { newCode in
                    if let code = newCode {
                        stepStateManager.updateCountry(code, templateVersion: 1)
                        // Trigger refresh to ensure UI updates
                        refreshTrigger.toggle()
                    }
                }
                .transition(.opacity)
                .zIndex(1)
                .id(refreshTrigger) // Force recreation when refresh is triggered
            }
            
            // Onboarding flow overlays
            if showCountrySelectionFromHome {
                // Country selection from HomeView (going back to change country)
                CountrySelectionView {
                    // When location is chosen, return to home
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.2)) {
                        showCountrySelectionFromHome = false
                        // Force update the step state manager and trigger UI refresh
                        if let selectedCountry = countryManager.selectedCountry {
                            stepStateManager.updateCountry(selectedCountry.code, templateVersion: 1)
                        }
                        refreshTrigger.toggle()
                    }
                }
                .environmentObject(countryManager)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .zIndex(3)
            }
            
            if shouldShowOnboarding && !showCountrySelection && !shouldShowAppOnboarding {
                // Start screen shown for users who completed app onboarding but not country selection
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
                .zIndex(2)
            }
            
            if showCountrySelection && (shouldShowOnboarding || shouldShowAppOnboarding) {
                // Country selection view for new users
                CountrySelectionView {
                    // When location is chosen, go to main app
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.2)) {
                        selectedTab = .home
                        showCountrySelection = false
                    }
                }
                .environmentObject(countryManager)
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: shouldShowOnboarding)
        .animation(.easeInOut(duration: 0.3), value: showCountrySelection)
        .animation(.easeInOut(duration: 0.3), value: showCountrySelectionFromHome)
        .onChange(of: showCountrySelectionFromHome) { newValue in
            // When returning from country selection, ensure we're in the right state
            if !newValue && !shouldShowOnboarding && !showCountrySelection {
                // Force a UI update by slightly delaying to ensure all states are synchronized
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // This triggers a UI refresh to ensure TabView appears
                    if let selectedCountry = countryManager.selectedCountry {
                        stepStateManager.updateCountry(selectedCountry.code, templateVersion: 1)
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
