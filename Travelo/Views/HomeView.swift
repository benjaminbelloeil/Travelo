//
//  Home.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 15/10/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header section
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome back!")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Explore Italy")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color("Primary"))
                        }
                        
                        Spacer()
                        
                        // Profile button
                        Button(action: {}) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(Color("Primary"))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Featured destinations
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Featured Destinations")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("See all") {
                                // Action
                            }
                            .font(.subheadline)
                            .foregroundColor(Color("Primary"))
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<3) { _ in
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 200, height: 150)
                                        .overlay(
                                            VStack {
                                                Spacer()
                                                Text("Destination")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .padding(.bottom, 16)
                                            }
                                        )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Quick actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            QuickActionCard(icon: "map.fill", title: "Explore Map", color: .blue)
                            QuickActionCard(icon: "book.fill", title: "Travel Guide", color: .green)
                            QuickActionCard(icon: "camera.fill", title: "Photo Gallery", color: .orange)
                            QuickActionCard(icon: "heart.fill", title: "Saved Places", color: .red)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100) // Space for bottom navigation
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
        }
    }
}

#Preview {
    HomeView()
}
