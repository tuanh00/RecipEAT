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
    
    
    var body: some View {
       
        VStack {
            if userLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
            
        }.onAppear{
            
            _ = Auth.auth().addStateDidChangeListener{
                auth, user in
                
                if (user != nil) {
                    userLoggedIn = true
                } else {
                    userLoggedIn = false
                }
            }
        }
    }
}

#Preview {
    InitialView()
}
