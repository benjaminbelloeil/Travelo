//
//  OnBoardingView.swift
//  Travelo
//
//  Created by Chiara Sotira on 24/10/25.
//

import SwiftUI

struct OnBoardingView: View {
    @State var CountingVar = 0
    
    var myBlue = Color(red: 148/255, green: 204/255, blue: 218/255)
    
    var body: some View {
        
        VStack {
            if  CountingVar == 0 {
                StartingPageView (text: PageText (title: "WELCOME TO ITALY", description: "Your step-by-step guide for Mexicans students studying abroad."),
                                  currentPage:  $CountingVar)
                
            }
            else if CountingVar == 1 {
                StartingPageView (text: PageText (title: "DOCUMENTS MADE SIMPLE", description: "We explain visas, permits, and health insurance so you don’t miss anything."),
                                  currentPage:  $CountingVar)
            }
            else if CountingVar == 2 {
                StartingPageView (text: PageText (title: "STAY BALANCED", description: "Find meditation and relaxation tips to manage stress during your exchange"),
                                  currentPage:  $CountingVar)
            }
            
            
            
        }
        
        
    }
    
}


#Preview {
    OnBoardingView()
}
