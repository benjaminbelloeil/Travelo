//
//  HomeView.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 15/10/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    @State private var completedSteps: [Bool] = [true, false, false]
    @EnvironmentObject var countryManager: CountryManager
    
    // Callback to notify when user taps on country name to change country
    var onCountryTap: (() -> Void)?
    
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
                    
                    // Maldives Island section
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
                        
                        VStack(spacing: 0) { // Changed to 0 spacing for continuous timeline
                            StepItem(
                                index: 0,
                                date: "12 oct",
                                title: "Codice Fiscale",
                                description: "Required for opening a bank account and signing rental contracts...",
                                isCompleted: $completedSteps[0],
                                canToggle: true,
                                isActive: !completedSteps[0],
                                isLastItem: false
                            )
                            
                            StepItem(
                                index: 1,
                                date: "18 oct",
                                title: "Permesso di Soggiorno",
                                description: "Submit application within 8 days of arrival.",
                                isCompleted: $completedSteps[1],
                                canToggle: completedSteps[0], // Can only check if previous is complete
                                isActive: completedSteps[0] && !completedSteps[1],
                                isLastItem: false
                            )
                            
                            StepItem(
                                index: 2,
                                date: "25 oct",
                                title: "Tessera Sanitaria",
                                description: "Needed to access Italy's public healthcare system.",
                                isCompleted: $completedSteps[2],
                                canToggle: completedSteps[1], // Can only check if previous is complete
                                isActive: completedSteps[1] && !completedSteps[2],
                                isLastItem: true
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100) // Space for bottom navigation
                }
            }
            .navigationBarHidden(true)
            .background(Color.white)
        }
    }
}

struct StepItem: View {
    let index: Int
    let date: String
    let title: String
    let description: String
    @Binding var isCompleted: Bool
    let canToggle: Bool
    let isActive: Bool
    let isLastItem: Bool
    @State private var animateTimeline = false
    @State private var showDisabledFeedback = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // Date
                VStack {
                    Text(date)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 60)
                
                // Timeline indicator - Modified structure
                ZStack(alignment: .top) {
                    // Vertical line that extends through the entire height
                    if !isLastItem {
                        Rectangle()
                            .fill(isCompleted ? Color("Primary") : Color.gray.opacity(0.2))
                            .frame(width: 3, height: 100) // Increased from 80 to 100 for more spacing
                            .offset(y: 26) // Start from bottom of circle
                            .animation(.easeInOut(duration: 0.4), value: isCompleted)
                    }
                    
                    // Circle on top
                    Group {
                        if isCompleted {
                            // Completed: solid Primary fill
                            Circle()
                                .fill(Color("Primary"))
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 32, height: 32)
                                )
                        } else if isActive {
                            // Active (not completed): outlined ring (white fill, Primary stroke)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Circle()
                                        .stroke(Color("Primary"), lineWidth: 3)
                                )
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 32, height: 32)
                                )
                        } else {
                            // Pending: gray fill
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 32, height: 32)
                                )
                        }
                    }
                    .scaleEffect(isActive ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isActive)
                }
                .frame(width: 32) // Fixed width for timeline column
                
                // Content - Extended to take more horizontal space
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Take maximum available width
                .padding(.trailing, 8) // Small padding before button
                
                // Interactive status button
                Button(action: toggleCompletion) {
                    Image(systemName: isCompleted ? "checkmark" : "xmark")
                        .font(.system(size: 20, weight: .thin))
                        .foregroundColor(isCompleted ? .green : (canToggle ? .gray : .gray.opacity(0.4)))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(isCompleted ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                        .overlay(
                            showDisabledFeedback && !canToggle ?
                            Text("Complete previous step first")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(6)
                                .shadow(radius: 2)
                                .offset(x: -100, y: 0)
                                .transition(.opacity)
                            : nil
                        )
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!canToggle && !isCompleted) // Can uncheck completed items but not check if previous isn't done
            }
            .frame(height: 100) // Increased from 80 to 100 for more spacing between steps
        }
    }
    
    private func toggleCompletion() {
        // Check if can toggle
        if !canToggle && !isCompleted {
            withAnimation(.easeInOut(duration: 0.2)) {
                showDisabledFeedback = true
            }
            
            // Haptic feedback for error
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDisabledFeedback = false
                }
            }
            return
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isCompleted.toggle()
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        if isCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    animateTimeline = true
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CountryManager())
}
