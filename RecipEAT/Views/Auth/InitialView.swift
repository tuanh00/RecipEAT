//
//  InitialView.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-17.
//

import SwiftUI
import FirebaseAuth

struct InitialView: View {
    //environment objects
    @StateObject private var userService = UserFirebaseService()
    @StateObject private var recipeService = RecipeService()
    @StateObject private var mealPlanService = MealPlanService()
    
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)
    @State private var showSignIn = true
    // controls presentation of SignInView
    var body: some View {
        ContentView()
            .fullScreenCover(isPresented: $showSignIn) {
                // Pass the binding to allow SignInView to dismiss itself on success.
                SignInView(showModal: $showSignIn)
            }
            .onAppear {
                _ = Auth.auth().addStateDidChangeListener { auth, user in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                        if showSignIn {
                            print("User is on Sign-In screen, keeping it open.")
                        } else {
                            print("Navigating to Home Screen.")
                            userLoggedIn = (user != nil)
                            showSignIn = (user == nil)
                        }
                    }
                }
            }
            .environmentObject(userService)//environment object for SignupView
            .environmentObject(recipeService)   // Inject RecipeService here
            .environmentObject(mealPlanService)

    }
}

#Preview {
    InitialView()
}
