//
//  GuideView.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 15/10/25.
//

import SwiftUI

struct GuideView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    
                    Text("Guide")
                        .font(.title)
                        .fontWeight(.medium)
                    
                    Text("Discover travel guides and tips")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .navigationTitle("Guide")
        }
    }
}
