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
                    .blur(radius: 3)
                    .ignoresSafeArea(.all)
                
                // Dark overlay for readability
                Color.black.opacity(0.35)
                    .ignoresSafeArea(.all)
                
                // Foreground content
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
                    
                    // Spacing before cards
                    Spacer().frame(height: 16)
                    
                    // Slider with mini preview cards that controls the selected page
                    ZStack {
                        TabView(selection: $selectedIndex) {
                            ForEach(Array(CountryManager.availableCountries.enumerated()), id: \.offset) { index, country in
                                // Card
                                ZStack(alignment: .bottomLeading) {
                                    Image(country.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 140)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(16)
                                    
                                    // Gradient overlay for text readability
                                    LinearGradient(
                                        colors: [Color.black.opacity(0.0), Color.black.opacity(0.5)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .cornerRadius(16)
                                    .frame(height: 120)
                                    
                                    Text(country.title)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.bottom, 12)
                                }
                                .padding(.horizontal, 28)
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 140)
                        
                        // Custom page indicators positioned at the bottom of the card
                        HStack(spacing: 8) {
                            ForEach(0..<CountryManager.availableCountries.count, id: \.self) { index in
                                Circle()
                                    .fill(index == selectedIndex ? Color.white : Color.white.opacity(0.5))
                                    .frame(width: 8, height: 8)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            selectedIndex = index
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 8)
                    }
                    .frame(height: 140)
                    .padding(.top, 6)
                    
                    // Choose Location button BELOW the cards
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
                    .padding(.top, 20)
                    .padding(.bottom, 10) // bottom spacing to match StartView
                    
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottom)
                .ignoresSafeArea(.all)
            }
        }
    }
}

#Preview {
    CountrySelectionView()
}
