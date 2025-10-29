//
//  Navigation.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 15/10/25.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case home = "Home"
    case map = "Map"
    case guide = "Guide"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home:
            return "house"
        case .map:
            return "map"
        case .guide:
            return "location"
        case .profile:
            return "person"
        }
    }
}

struct BottomNavigationView: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                
                VStack(spacing: 6) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == tab ? Color("Primary") : .gray)
                    
                    Text(tab.rawValue)
                        .font(.caption2)
                        .foregroundColor(selectedTab == tab ? Color("Primary") : .gray)
                }
                .padding(.top, 16)
                .onTapGesture {
                    selectedTab = tab
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ContentView()
}
