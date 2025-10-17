//
//  StartView.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 15/10/25.
//

import SwiftUI
import Combine

struct StartView: View {
    @State private var currentImageIndex = 0
    private let images = ["HomeImage", "HomeImage2", "HomeImage3", "HomeImage4"]
    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    // Callback to notify when user taps Start
    var onStart: (() -> Void)?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: Background images with smooth transitions
                ForEach(0..<images.count, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                        .ignoresSafeArea(.all)
                        .opacity(currentImageIndex == index ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.5), value: currentImageIndex)
                }
                
                // MARK: Dark overlay for better text readability
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack {
                    // MARK: Title text
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("YOUR")
                            Text("LIVING")
                            Text("GUIDE")
                            Text("AROUND")
                            Text("THE WORLD")
                        }
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 40)
                        .padding(.top, 60)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // MARK: Start Button
                    Button(action: {
                        onStart?()
                    }) {
                        Text("START")
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
                    .padding(.bottom, 10)
                }
            }
            .onReceive(timer) { _ in
                withAnimation {
                    currentImageIndex = (currentImageIndex + 1) % images.count
                }
            }
        }
    }
}

#Preview {
    StartView()
}
