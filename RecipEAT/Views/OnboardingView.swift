//
//  OnboardingView.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-19.
//

import SwiftUI
import RiveRuntime

struct OnboardingView: View {
    let button = RiveViewModel(fileName: "button")
    
    var body: some View {
        ZStack {
            
            background
            
            content
            
        }
        
    }// end of View
    var background: some View {
        RiveViewModel(fileName: "shapes").view()
            .ignoresSafeArea()
            .blur(radius: 30)
            .background(
                Image("Spline")
                    .blur(radius: 50)
                    .offset(x: 200, y: 100)
            )
    }
    var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lorem Ipsum")
            //                .font(.custom("Poppins Bold", size: 60, relativeTo: .largeTitle))
                .customFont(.largeTitle)
                .frame(width: 260, alignment: .leading)
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. In vitae condimentum neque. Proin augue mauris, luctus et ex sed, convallis tristique nunc.")
                .customFont(.body)
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            button.view()
                .frame(width: 236, height: 64)
                .overlay(
                    Label("Click me", systemImage: "arrow.forward")
                        .offset(x: 4, y: 4)
                        .font(.headline)
                )
                .background(
                    Color.black
                        .cornerRadius(30)
                        .blur(radius: 10)
                        .opacity(0.3)
                        .offset(y: 10)
                )
                .onTapGesture {
                    button.play(animationName: "active")
                    //after a few seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        //                        withAnimation(.spring()) {
                        //                            showModal = true
                        //                        }
                    }
                }
            
            Text("Suspendisse fermentum enim ac nisi efficitur, non hendrerit nisi lobortis. Lorem ipsum dolor sit amet.")
                .customFont(.footnote)
                .opacity(0.7)
        }
        .padding(40)
        .padding(.top, 40)
        
    }
    
}

#Preview {
    OnboardingView()
}
