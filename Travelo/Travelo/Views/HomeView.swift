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
    @EnvironmentObject var profileManager: UserProfileManager
    @Environment(\.tabSelection) var tabSelection
    @Environment(\.showCountrySelection) var showCountrySelection
    
    // State for navigation through step groups
    @State private var currentStepGroup: Int = 0
    
    // Dynamic greeting based on time
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        case 17..<21:
            return "Good evening"
        default:
            return "Good night"
        }
    }
    
    // User's display name or default
    private var displayName: String {
        let firstName = profileManager.userProfile.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return firstName.isEmpty ? "User" : firstName
    }
    
    var allSteps: [StepItem] {
        guard let selectedCountry = countryManager.selectedCountry else { return [] }
        return StepItem.steps(for: selectedCountry.code).sorted { $0.order < $1.order }
    }
    
    var visibleSteps: [StepItem] {
        let stepsPerGroup = 3
        let startIndex = currentStepGroup * stepsPerGroup
        let endIndex = min(startIndex + stepsPerGroup, allSteps.count)
        return Array(allSteps[startIndex..<endIndex])
    }
    
    var totalGroups: Int {
        let stepsPerGroup = 3
        return (allSteps.count + stepsPerGroup - 1) / stepsPerGroup
    }
    
    var canNavigateBack: Bool {
        return currentStepGroup > 0
    }
    
    var canNavigateForward: Bool {
        return currentStepGroup < totalGroups - 1
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header section
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(timeBasedGreeting)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text("Hello, \(displayName)!")
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        // Profile avatar (synced with ProfileView)
                        Button(action: {
                            tabSelection.wrappedValue = .profile
                        }) {
                            ProfileImageView(
                                imageData: profileManager.userProfile.profileImageData,
                                initials: profileManager.userProfile.initials,
                                size: 48,
                                showCameraOverlay: false
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
                                        
                                        Text(countryManager.currentLocationTag)
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
                                        showCountrySelection()
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
                        HStack(alignment: .center) {
                            Text("Your next steps")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            // Navigation arrows
                            HStack(spacing: 12) {
                                // Back arrow
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentStepGroup = max(0, currentStepGroup - 1)
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(canNavigateBack ? .black : .gray.opacity(0.4))
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle()
                                                .fill(.gray.opacity(canNavigateBack ? 0.15 : 0.05))
                                        )
                                }
                                .disabled(!canNavigateBack)
                                
                                // Forward arrow
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentStepGroup = min(totalGroups - 1, currentStepGroup + 1)
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(canNavigateForward ? .black : .gray.opacity(0.4))
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle()
                                                .fill(.gray.opacity(canNavigateForward ? 0.15 : 0.05))
                                        )
                                }
                                .disabled(!canNavigateForward)
                            }
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
                                            
                                            // Check if we just completed the last step in the current group
                                            // and if there are more groups to navigate to
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                checkForAutoNavigation()
                                            }
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
                // Navigate to the group with the first incomplete step
                updateCurrentStepGroup()
            }
            .onChange(of: countryManager.selectedCountry?.code) { newCode in
                if let code = newCode {
                    stepStateManager.updateCountry(code, templateVersion: 1)
                    // Reset to the appropriate group when country changes
                    currentStepGroup = 0
                    updateCurrentStepGroup()
                }
            }
        }
    }
    
    // Helper function to navigate to the group containing the first incomplete step
    private func updateCurrentStepGroup() {
        let stepsPerGroup = 3
        
        // Find first incomplete step
        if let firstIncompleteIndex = allSteps.firstIndex(where: { !stepStateManager.isDone($0.id) }) {
            let targetGroup = firstIncompleteIndex / stepsPerGroup
            currentStepGroup = min(targetGroup, totalGroups - 1)
        } else if !allSteps.isEmpty {
            // All steps complete, show the last group
            currentStepGroup = max(0, totalGroups - 1)
        }
    }
    
    // Helper function to check if we should automatically navigate after completing a step
    private func checkForAutoNavigation() {
        let stepsPerGroup = 3
        
        // Check if all steps in current group are completed
        let allCurrentGroupStepsCompleted = visibleSteps.allSatisfy { step in
            stepStateManager.isDone(step.id)
        }
        
        // If all steps in current group are completed and there are more groups ahead
        if allCurrentGroupStepsCompleted && canNavigateForward {
            // Automatically move to next group after a short delay for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    currentStepGroup = min(totalGroups - 1, currentStepGroup + 1)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CountryManager())
        .environmentObject(StepStateManager())
        .environmentObject(UserProfileManager())
        .environment(\.tabSelection, .constant(.home))
        .environment(\.showCountrySelection, {})
}
