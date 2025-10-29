//
//  GuideView.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 15/10/25.
//

import SwiftUI

struct GuideView: View {
    @EnvironmentObject var countryManager: CountryManager
    @EnvironmentObject var stepStateManager: StepStateManager
    
    var steps: [StepItem] {
        guard let selectedCountry = countryManager.selectedCountry else { return [] }
        return StepItem.steps(for: selectedCountry.code).sorted { $0.order < $1.order }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Header section
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Complete Guide")
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundColor(.black)
                            
                            Text("Step-by-step bureaucratic process for \(countryManager.selectedCountry?.title ?? "your destination")")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Steps timeline
                    VStack(spacing: 0) {
                        ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                            NavigationLink(destination: StepDetailView(stepInfo: step)) {
                                StepRow(
                                    item: step,
                                    isDone: stepStateManager.isDone(step.id),
                                    onToggle: { stepStateManager.toggle(step.id) },
                                    index: index,
                                    isLastItem: index == steps.count - 1,
                                    canToggle: stepStateManager.canToggleStep(step, in: steps),
                                    isActive: stepStateManager.isStepActive(step, in: steps)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Informational card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color("Primary"))
                            
                            Text("Tip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        Text("Click on any step above to learn more detailed information about the requirements, documents needed, and helpful tips for completing each step successfully.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 4) // Reduced from 8 to 4 to be closer to last step
                    .padding(.bottom, 20) // Added bottom padding so it doesn't stick to navbar
                }
            }
            .navigationBarHidden(true)
            .background(Color.white)
        }
    }
}

#Preview {
    GuideView()
}
