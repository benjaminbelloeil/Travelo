//
//  ProfileView.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 15/10/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.purple)
                    
                    Text("Profile")
                        .font(.title)
                        .fontWeight(.medium)
                    
                    Text("Manage your account and preferences")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}
