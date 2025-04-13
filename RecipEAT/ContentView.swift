//
//  ContentView.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-17.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house")
                }
                .tag(0)
            
            PersonalRecipeScreen()
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
        .navigationDestination(for: RecipeWrapper.self) { wrapper in
            RecipeDetails(recipe: wrapper.recipe, isMyRecipe: wrapper.isMyRecipe)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("GoToHomeTab"))) {
            _ in
            selectedTab = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("GoToMyRecipesTab"))) { _ in
            selectedTab = 1  // PersonalRecipeScreen
        }
    }
}

#Preview {
    ContentView()
}
