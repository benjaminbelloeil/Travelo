//
//  StepDetailView.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 23/10/25.
//
import Foundation
import SwiftUI

struct StepDetailView: View {
    @State var stepInfo: StepItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header with step number and title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Step \(stepInfo.stepNumber)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("Primary"))
                    
                    Text(stepInfo.title)
                        .font(.system(size: 34))
                        .fontWeight(.heavy)
                }
                .padding(.bottom, 16)
                
                StepDetailSection(title: "What is it?", description: stepInfo.whatIs)
                
                StepDetailSection(title: "Why do you need it?", description: stepInfo.whyIs)
                
                StepDetailSection(title: "Where to get it?", description: stepInfo.whereIs)
                
                StepDetailSection(title: "When to get it?", description: stepInfo.whenIs)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Documents required")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                    
                    ForEach(stepInfo.docRequired, id: \.self) { document in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color("Primary"))
                            
                            Text(document)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Useful links / addresses")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                    
                    ForEach(stepInfo.usefulLinks, id: \.self) { link in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color("Primary"))
                            
                            Text(link)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StepDetailSection: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20))
                .fontWeight(.bold)
            
            Text(description)
                .font(.system(size: 16))
                .fontWeight(.medium)
                .lineSpacing(4)
        }
        .padding(.bottom, 16)
    }
}

#Preview {
    NavigationView {
        StepDetailView(stepInfo: StepItem.italySteps[0])
    }
}

