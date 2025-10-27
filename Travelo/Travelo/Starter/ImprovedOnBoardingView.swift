//
//  ImprovedOnBoardingView.swift
//  Travelo
//
//  Created by Assistant on 10/27/25.
//

import SwiftUI

struct ImprovedOnBoardingView: View {
    @State private var countingVar = 0
    @State private var showStartView = false
    
    var onComplete: () -> Void
    
    var myBlue = Color(red: 148/255, green: 204/255, blue: 218/255)
    
    var body: some View {
        ZStack {
            if !showStartView {
                if countingVar == 0 {
                    ImprovedStartingPageView(
                        text: PageText(
                            title: "WELCOME TO ITALY",
                            description: "Your step-by-step guide for Mexican students studying abroad."
                        ),
                        currentPage: $countingVar,
                        isLastPage: false
                    )
                } else if countingVar == 1 {
                    ImprovedStartingPageView(
                        text: PageText(
                            title: "DOCUMENTS MADE SIMPLE",
                            description: "We explain visas, permits, and health insurance so you don't miss anything."
                        ),
                        currentPage: $countingVar,
                        isLastPage: false
                    )
                } else if countingVar == 2 {
                    ImprovedStartingPageView(
                        text: PageText(
                            title: "STAY BALANCED",
                            description: "Find meditation and relaxation tips to manage stress during your exchange."
                        ),
                        currentPage: $countingVar,
                        isLastPage: true,
                        onComplete: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                                showStartView = true
                            }
                        }
                    )
                }
            } else {
                StartView {
                    onComplete()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }
}

struct ImprovedStartingPageView: View {
    let text: PageText
    @State private var animateClouds = false
    @Binding var currentPage: Int
    let isLastPage: Bool
    var onComplete: (() -> Void)? = nil
    
    var myBlue = Color(red: 148/255, green: 204/255, blue: 218/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with animated clouds
            VStack {
                Spacer()
                
                // Animated clouds
                ZStack {
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .frame(width: 120, height: 70)
                        .foregroundStyle(myBlue.opacity(0.8))
                        .offset(x: animateClouds ? 80 : -80, y: -20)
                    
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .frame(width: 100, height: 60)
                        .foregroundStyle(myBlue.opacity(0.6))
                        .offset(x: animateClouds ? -60 : 60, y: 20)
                    
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .frame(width: 80, height: 50)
                        .foregroundStyle(myBlue.opacity(0.4))
                        .offset(x: animateClouds ? 40 : -40, y: -10)
                }
                .frame(height: 150)
                
                Spacer()
            }
            .frame(height: UIScreen.main.bounds.height * 0.4)
            
            // Content section
            VStack(alignment: .leading, spacing: 24) {
                // Title
                HStack {
                    Text(text.title)
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Description
                HStack {
                    Text(text.description)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Page indicators - centered above the button
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color("Primary") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .frame(maxWidth: .infinity) // This ensures the HStack takes full width
                .padding(.bottom, 20) // Space between dots and button
                
                // Action button
                Button(action: {
                    if isLastPage {
                        onComplete?()
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    }
                }) {
                    HStack {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if !isLastPage {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("Primary"))
                    .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animateClouds.toggle()
            }
        }
    }
}

#Preview {
    ImprovedOnBoardingView(onComplete: {})
}