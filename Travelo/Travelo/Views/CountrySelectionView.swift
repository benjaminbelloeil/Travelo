//
//  CountrySelectionView.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 15/10/25.
//

import SwiftUI
import Combine

struct CountrySelectionView: View {
    // Callback to notify when user taps Choose Location
    var onStart: (() -> Void)?
    @EnvironmentObject var countryManager: CountryManager
    
    @State private var selectedIndex: Int = 0
    
    // Initialize with the current selected country
    private func initializeSelectedIndex() {
        if let currentCountry = countryManager.selectedCountry,
           let index = CountryManager.availableCountries.firstIndex(where: { $0.code == currentCountry.code }) {
            selectedIndex = index
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            let selected = CountryManager.availableCountries[selectedIndex]
            
            ZStack {
                // Background image fills the entire screen
                Image(selected.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea(.all)
                
                // Dark overlay for readability
                Color.black.opacity(0.35)
                    .ignoresSafeArea(.all)
                
                // Foreground content - positioned to match START button layout
                VStack(spacing: 0) {
                    Spacer() // pushes content to bottom
                    
                    // Title + description for the selected page  
                    VStack(alignment: .leading, spacing: 14) {
                        Text(selected.title)
                            .font(.system(size: 40, weight: .heavy))
                            .foregroundColor(.white)
                            .kerning(0.5)
                        
                        Text(selected.description)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 20) // Add bottom padding to push everything lower
                    
                    // Page indicators above the button
                    HStack(spacing: 8) {
                        ForEach(0..<CountryManager.availableCountries.count, id: \.self) { index in
                            Circle()
                                .fill(index == selectedIndex ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 6, height: 6)
                                .scaleEffect(index == selectedIndex ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        selectedIndex = index
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.1))
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                    )
                    .padding(.bottom, 20) // Increased spacing above button
                    
                    // Choose Location button positioned to match START button height exactly
                    Button(action: { 
                        // Select the current country
                        countryManager.selectCountry(CountryManager.availableCountries[selectedIndex])
                        // Call the callback to navigate
                        onStart?() 
                    }) {
                        Text("Choose Location")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                            )
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, -50) // Exact match with START button padding
                    
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottom)
                .ignoresSafeArea(.all)
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width > threshold {
                            // Swipe right - go to previous country
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedIndex = max(0, selectedIndex - 1)
                            }
                        } else if value.translation.width < -threshold {
                            // Swipe left - go to next country
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedIndex = min(CountryManager.availableCountries.count - 1, selectedIndex + 1)
                            }
                        }
                    }
            )
            .onAppear {
                // Initialize with current country when view appears
                initializeSelectedIndex()
            }
        }
    }
}

#Preview {
    CountrySelectionView()
}
