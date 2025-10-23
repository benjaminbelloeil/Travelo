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
                    
                    Spacer(minLength: 100) // Space for bottom navigation
                }
            }
            .navigationBarHidden(true)
            .background(Color.white)
        }
    }
}
