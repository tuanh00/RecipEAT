//
//  ContentView.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-17.
//

import SwiftUI

struct ContentView: View {
    @State private var error: String = ""
    @State private var selectedTab: Int = 0

    var body: some View {
        VStack {
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
        
        TabView(selection: $selectedTab) {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house")
                }
                .tag(0)

            SavedListScreen()
                .tabItem {
                    Image(systemName: "book.pages.fill")
                }.tag(1)

            CreateNewRecipeScreen(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "plus.app.fill")
                }.tag(2)

            MealPlannerScreen(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "calendar")
                }.tag(3)

            ProfileScreen()
                .tabItem {
                    Image(systemName: "person.fill")
                }.tag(4)

        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("GoToHomeTab"))) {
            _ in
            selectedTab = 0
        }
    }
}

#Preview {
    ContentView()
}
