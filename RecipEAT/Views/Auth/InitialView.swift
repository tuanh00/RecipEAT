//
//  InitialView.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-17.
//

import SwiftUI
import FirebaseAuth

struct InitialView: View {
    @StateObject private var userService = UserFirebaseService()
    @StateObject private var recipeService = RecipeService()
    @StateObject private var mealPlanService = MealPlanService()
    
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)
    @State private var showSignIn = true
    var body: some View {
        //        ContentView()
        //            .fullScreenCover(isPresented: $showSignIn) {
        //                // Pass the binding to allow SignInView to dismiss itself on success.
        //                SignInView(showModal: $showSignIn)
        //            }
        Group {
            if userService.currentUser == nil {
                SignInView(showModal: $showSignIn)
            } else {
                NavigationStack {
                    ContentView()
                }
            }
        }
        .onAppear {
            //                _ = Auth.auth().addStateDidChangeListener { auth, user in
            //                    DispatchQueue.main.async {
            //                        if let _ = user {
            ////                            print("Navigating to Home Screen.")
            //                            userLoggedIn = true
            //                            showSignIn = false
            //                            // Load current user's Firestore data if not already loaded.
            //                            if self.userService.currentUser == nil {
            //                                self.userService.loadCurrentUser { error in
            //                                    if let error = error {
            //                                        print("Error loading current user: \(error.localizedDescription)")
            //                                    }
            //                                }
            //                            }
            //                        } else {
            //                            print("User is on Sign-In screen, keeping it open.")
            //                            userLoggedIn = false
            //                            showSignIn = true
            //                        }
            //                    }
            //                }
            _ = Auth.auth().addStateDidChangeListener { auth, user in
                DispatchQueue.main.async {
                    if let _ = user {
                        print("User session found, loading Firestore user...")
                        userService.loadCurrentUser { error in
                            if let error = error {
                                print("Failed to load user: \(error.localizedDescription)")
                                showSignIn = true
                            } else {
                                print("Loaded Firestore user successfully.")
                                showSignIn = false
                            }
                        }
                    } else {
                        print("No authenticated session, show sign-in screen.")
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
