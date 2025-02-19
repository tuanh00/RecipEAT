//
//  InitialView.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-17.
//

import SwiftUI
import FirebaseAuth

struct InitialView: View {
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)
    @State private var showSignIn = true  // controls presentation of SignInView
    
    var body: some View {
        ContentView()
            .fullScreenCover(isPresented: $showSignIn) {
                // Pass the binding to allow SignInView to dismiss itself on success.
                SignInView(showModal: $showSignIn)
            }
            .onAppear {
                _ = Auth.auth().addStateDidChangeListener { auth, user in
                    userLoggedIn = (user != nil)
                    // Show the sign in screen only when there’s no logged in user.
                    showSignIn = (user == nil)
                }
            }
    }
}

#Preview {
    InitialView()
}
