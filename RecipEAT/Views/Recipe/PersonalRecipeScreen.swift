//
//  PersonalRecipeScreen.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-03-16.
//

import SwiftUI
import Firebase

struct PersonalRecipeScreen: View {
    @EnvironmentObject var userService: UserFirebaseService
    @EnvironmentObject var recipeService: RecipeService

    @State private var selectedTab = 0  // 0: Saved, 1: Liked, 2: My Recipes
    @State private var allRecipes: [Recipe] = []

    var body: some View {
        VStack {
            Picker("", selection: $selectedTab) {
                Text("Saved").tag(0)
                Text("Liked").tag(1)
                Text("My Recipes").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedTab == 0 {
                RecipeScreen(
                    recipes: recipeService.filterRecipesBySavedList(
                        allRecipes: allRecipes,
                        savedIds: userService.currentUser?.savedRecipes ?? []
                    )
                )
            } else if selectedTab == 1 {
                RecipeScreen(
                    recipes: recipeService.filterRecipesByLikedList(
                        allRecipes: allRecipes,
                        likedIds: userService.currentUser?.likedRecipes ?? []
                    )
                )
            } else {
                RecipeScreen(
                    recipes: allRecipes,
                    isMyRecipes: true  // <--- important flag for UpdateRecipeScreen navigation
                )
            }
        }
        .navigationTitle("Personal Recipes")
        .onAppear {
            fetchRecipes()
        }
        .onChange(of: selectedTab) { _, _ in
            fetchRecipes()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("GoToMyRecipesTab"))) { _ in
                    selectedTab = 2
                    fetchRecipes()
                }
    }

    private func fetchRecipes() {
        guard let userId = userService.currentUser?.id else { return }

        if selectedTab == 2 {
            recipeService.fetchRecipesByCurrentUser(userId: userId) { recipes in
                self.allRecipes = recipes
            }
        } else {
            recipeService.fetchPublishedRecipes { recipes in
                self.allRecipes = recipes
            }
        }
    }
}
