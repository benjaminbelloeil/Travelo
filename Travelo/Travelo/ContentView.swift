//
//  ContentView.swift
//  Travelo
//
//  Created by Dawar Hasnain on 10/10/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var hasSeenStartThisSession: Bool = false
    @State private var showCountrySelection: Bool = false
    @State private var showCountrySelectionFromHome: Bool = false
    @StateObject private var countryManager = CountryManager()
    @StateObject private var stepStateManager = StepStateManager()
    
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
            } else if !hasSeenStartThisSession && !showCountrySelection {
                // Start screen shown every app open
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
            } else if showCountrySelection && !hasSeenStartThisSession {
                // Country selection view
                CountrySelectionView {
                    // When location is chosen, go to main app
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.2)) {
                        selectedTab = .home
                        hasSeenStartThisSession = true
                        showCountrySelection = false
                    }
                }
                .environmentObject(countryManager)
                .transition(.opacity) // Simple fade out, no sliding
            } else {
                VStack(spacing: 0) {
                    // Main content area with simple fade transitions
                    ZStack {
                        tabView(for: selectedTab)
                            .id(selectedTab)
                            .transition(.opacity) // Simple fade transition for tabs
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Bottom navigation
                    BottomNavigationView(selectedTab: $selectedTab)
                }
                .environmentObject(countryManager)
                .environmentObject(stepStateManager)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .transition(.asymmetric(
                    insertion: .opacity, // Simple fade in for main app
                    removal: .opacity
                ))
                .animation(.easeInOut(duration: 0.45), value: hasSeenStartThisSession)
                .onChange(of: countryManager.selectedCountry?.code) { newCode in
                    if let code = newCode {
                        stepStateManager.updateCountry(code, templateVersion: 1)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func tabView(for tab: Tab) -> some View {
        switch tab {
        case .home:
            HomeView {
                // Callback when user taps on country name to change country
                withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.2)) {
                    showCountrySelectionFromHome = true
                }
            }
        case .map:
            MapView()
        case .guide:
            GuideView()
        case .profile:
            ProfileView()
        }
    }
}

#Preview {
    ContentView()
}
