//
//  InitialView.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-17.
//

import SwiftUI
import FirebaseAuth

struct InitialView: View {
    // Environment objects
    @StateObject private var userService = UserFirebaseService()
    @StateObject private var recipeService = RecipeService()
    @StateObject private var mealPlanService = MealPlanService()
    
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)
    @State private var showSignIn = true
    var body: some View {
        ContentView()
            .fullScreenCover(isPresented: $showSignIn) {
                // Pass the binding to allow SignInView to dismiss itself on success.
                SignInView(showModal: $showSignIn)
            }
            .onAppear {
                _ = Auth.auth().addStateDidChangeListener { auth, user in
                    // FIX: Removed delay and load user data if authenticated.
                    DispatchQueue.main.async {
                        if let _ = user {
                            print("Navigating to Home Screen.")
                            userLoggedIn = true
                            showSignIn = false
                            // Load current user's Firestore data if not already loaded.
                            if self.userService.currentUser == nil {
                                self.userService.loadCurrentUser { error in
                                    if let error = error {
                                        print("Error loading current user: \(error.localizedDescription)")
                                    }
                                }
                            }
                        } else {
                            print("User is on Sign-In screen, keeping it open.")
                            userLoggedIn = false
                            showSignIn = true
                        }
                    }
                }
            }
            .environmentObject(userService)
            .environmentObject(recipeService)
            .environmentObject(mealPlanService)
    }
}

#Preview {
    InitialView()
}
