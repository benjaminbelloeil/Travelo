//
//  StartingPageView.swift
//  Travelo
//
//  Created by Chiara Sotira on 21/10/25.
//

import SwiftUI

struct StartingPageView: View {
    @State var text: PageText
    @State var animateClouds = false
    @State var isNavigating = false
    @Binding var currentPage: Int
    
    var myBlue = Color(red: 148/255, green: 204/255, blue: 218/255)
    var body: some View {
        
        NavigationStack {
            // Per l'allineamento verticale
            VStack () {
                
                Spacer()
                
                Image (systemName: "cloud.fill")
                    .resizable()
                    .frame( width: 150 , height: 80 )
                    .foregroundStyle(Color (myBlue))
                    .offset(x: animateClouds ? 100 : -100)
                    .padding(.bottom,30)
                Image (systemName: "cloud.fill")
                    .resizable()
                    .frame( width: 150 , height: 80 )
                    .foregroundStyle(Color (myBlue))
                    .offset(x: animateClouds ? -100: 100)
                
                Spacer()
                HStack{
                    Text(text.title)
                        .font(.title.bold())
                        .padding(.horizontal, 30)
                    Spacer()
                    
                }
                .padding(.bottom, 40)
                
            }
            HStack{
                Text(text.description)
                    .font(.headline)
                .padding(.bottom,72) }
            Spacer ()
            
            Button {
                currentPage += 1
            } label: {
                
                ZStack {
                    
                    Rectangle()
                        .frame(width: 150,height: 50)
                        .foregroundStyle(Color (myBlue))
                        .cornerRadius(55)
                    Image(systemName:"arrow.right")
                        .foregroundStyle(Color.white)
                        .frame(width:75,height:50)
                }
                
            }
            
        }
        .padding(.bottom,116)
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animateClouds.toggle()
            }
        }
    }
    
}


#Preview {
    StartingPageView(text: PageText(title: "WELCOME TO ITALY", description: "Your step-by-step guide for Mexicans students studying abroad."), currentPage: .constant(0) )
}
