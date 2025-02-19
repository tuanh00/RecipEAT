//
//  ContentView.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-17.
//

import SwiftUI

struct ContentView: View {
    @State private var error: String = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .customFont(.headline)
            
            Button{
                Task {
                    do {
                        try await AuthenticationView().logout()
                    } catch let e {
                        error = e.localizedDescription
                    }
                }
            } label: {
                Text("Log Out")
                    .customFont(.subheadline)
                    .padding(8)
            }
            .buttonStyle(.borderedProminent)
            
            Text(error)
                .foregroundColor(.red)
                .font(.caption)
        }.padding()
        
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house")
                }
            SavedListScreen()
                .tabItem {
                    Image(systemName: "book.pages.fill")
                }
            CreateNewRecipeScreen()
                .tabItem {
                    Image(systemName: "plus.app.fill")
                }
            MealPlannerScreen()
                .tabItem {
                    Image(systemName: "calendar")
                }
            ProfileScreen()
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
