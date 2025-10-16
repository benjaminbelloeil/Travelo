//
//  MapView.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 15/10/25.
//

import SwiftUI

struct MapView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Map")
                        .font(.title)
                        .fontWeight(.medium)
                    
                    Text("Explore destinations around you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .navigationTitle("Map")
        }
    }
}
