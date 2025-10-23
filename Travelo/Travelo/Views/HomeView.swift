//
//  HomeView.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 15/10/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var countryManager: CountryManager
    @EnvironmentObject var stepStateManager: StepStateManager
    
    // Callback to notify when user taps on country name to change country
    var onCountryTap: (() -> Void)?
    
    var allSteps: [StepItem] {
        guard let selectedCountry = countryManager.selectedCountry else { return [] }
        return StepItem.steps(for: selectedCountry.code).sorted { $0.order < $1.order }
    }
    
    var visibleSteps: [StepItem] {
        stepStateManager.getVisibleStepsForHome(allSteps: allSteps)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header section
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Good morning")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text("Hello, Benjamin!")
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        // Profile avatar (reduced size)
                        Button(action: {}) {
                            Circle()
                                .fill(Color("Primary"))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Destination card section
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Destination card (reduced height by 20%)
                        ZStack {
                            // Background image from selected country
                            if let selectedCountry = countryManager.selectedCountry {
                                Image(selectedCountry.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 192)
                                    .clipped()
                                    .cornerRadius(20)
                            } else {
                                // Fallback gradient if no country selected
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.8),
                                                Color.gray.opacity(0.6),
                                                Color.blue.opacity(0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 192)
                            }
                            
                            // Dark overlay for text readability
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.3))
                                .frame(height: 192)
                            
                            // Overlays
                            VStack {
                                HStack {
                                    // Location tag
                                    HStack(spacing: 4) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white)
                                        
                                        Text(countryManager.selectedCountry?.locationTag ?? "Select Country")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.black.opacity(0.3))
                                    .cornerRadius(12)
                                    
                                    Spacer()
                                }
                                .padding(.top, 16)
                                .padding(.leading, 16)
                                
                                Spacer()
                                
                                HStack {
                                    Spacer()
                                    
                                    // Country name pill
                                    HStack(spacing: 4) {
                                        Text(countryManager.selectedCountry?.title ?? "No Country")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.3))
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                                    .onTapGesture {
                                        onCountryTap?()
                                    }
                                }
                                .padding(.trailing, 16)
                                .padding(.bottom, 16)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Your next steps section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Your next steps")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(visibleSteps.enumerated()), id: \.element.id) { index, step in
                                StepRow(
                                    item: step,
                                    isDone: stepStateManager.isDone(step.id),
                                    onToggle: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            stepStateManager.toggle(step.id)
                                        }
                                    },
                                    index: index,
                                    isLastItem: index == visibleSteps.count - 1,
                                    canToggle: stepStateManager.canToggleStep(step, in: allSteps),
                                    isActive: stepStateManager.isStepActive(step, in: allSteps)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .animation(.easeInOut(duration: 0.4), value: visibleSteps.map { $0.id })
                    }
                    
                    Spacer(minLength: 100) // Space for bottom navigation
                }
            }
            .navigationBarHidden(true)
            .background(Color.white)
            .onAppear {
                if let selectedCountry = countryManager.selectedCountry {
                    stepStateManager.updateCountry(selectedCountry.code, templateVersion: 1)
                }
            }
            .onChange(of: countryManager.selectedCountry?.code) { newCode in
                if let code = newCode {
                    stepStateManager.updateCountry(code, templateVersion: 1)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CountryManager())
        .environmentObject(StepStateManager())
}
