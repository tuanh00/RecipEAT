//
//  RecipeCard.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe
    @EnvironmentObject var userService: UserFirebaseService
    @EnvironmentObject var recipeService:
    RecipeService
    @State private var latestRecipe: Recipe?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // IMAGE
                AsyncImage(url: URL(string: recipe.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 200)
                .clipped()

                // TEXT INFO
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title.capitalized)
                        .font(.headline)
                        .foregroundColor(.black)
                        .lineLimit(2)

                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                            Text("\(latestRecipe?.likeCount ?? recipe.likeCount)")
                        }
                        .foregroundColor(.red)

                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                            Text("\(recipe.servings) servings")
                        }
                        .foregroundColor(.gray)
                    }
                    .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.horizontal)

            // LIKE/SAVE overlay
            VStack(spacing: 12) {
                Button {
                    userService.toggleSaveRecipe(recipeId: recipe.id ?? "")
                    refreshRecipeData()
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(radius: 2)
                        .overlay(
                            Image(systemName: userService.currentUser?.savedRecipes.contains(recipe.id ?? "") == true ? "bookmark.fill" : "bookmark")
                                .foregroundColor(userService.currentUser?.savedRecipes.contains(recipe.id ?? "") == true ? .yellow : .gray)
                        )
                }

                Button {
                    userService.toggleLikeRecipe(recipeId: recipe.id ?? "")
                    refreshRecipeData()
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(radius: 2)
                        .overlay(
                            Image(systemName: userService.currentUser?.likedRecipes.contains(recipe.id ?? "") == true ? "heart.fill" : "heart")
                                .foregroundColor(userService.currentUser?.likedRecipes.contains(recipe.id ?? "") == true ? .red : .gray)
                        )
                }
            }
            .padding(.trailing, 26)
            .padding(.bottom, 12)
            .zIndex(1)
        }

        
        .onAppear {
            refreshRecipeData()
        }
    }
    private func refreshRecipeData() {
        if let recipeId = recipe.id {
            recipeService.fetchRecipeById(recipeId) { updated in
                if let updated = updated {
                    DispatchQueue.main.async {
                        latestRecipe = updated
                    }
                }
            }
        }
    }
}




struct RecipeCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRecipe = Recipe(
            id: "sample1",
            imageUrl: "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?q=80&w=2080&auto=format&fit=crop",
            title: "Creamy Tomato Pasta",
            description: "A delicious creamy pasta recipe.",
            ingredients: [
                Ingredients(name: "Tomato", quantity: "2", unit: "units"),
                Ingredients(name: "Cream", quantity: "200", unit: "grams"),
                Ingredients(name: "Pasta", quantity: "1", unit: "pack")
            ],
            instructions: ["Boil pasta", "Prepare sauce", "Mix and serve"],
            userId: "user123",
            category: "Dinner",
            review: [],
            servings: 2,
            createdAt: Date(),
            isPublished: true,
            likeCount: 5,
            saveCount: 10
        )
        
        let mockUserService = UserFirebaseService()
        mockUserService.currentUser = User(
            id: "user123",
            email: "sample@example.com",
            displayName: "Test User",
            imageUrl: "",
            password: "",
            createdAt: Date(),
            savedRecipes: ["sample1"],
            likedRecipes: []
        )
        
        let mockRecipeService = RecipeService()
        
        return RecipeCard(recipe: sampleRecipe)
            .environmentObject(mockUserService)
            .environmentObject(mockRecipeService)
    }
}
