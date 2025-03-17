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
    @State private var navigate = false

    var body: some View {
        // Keep the same ZStack approach
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(isActive: $navigate) {
                RecipeDetails(recipe: recipe)
            } label: {
                EmptyView()
            }
            .hidden()

            // 2) Card Content
            VStack(spacing: 0) {
                // IMAGE
                AsyncImage(url: URL(string: recipe.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .frame(height: 200)
                        .clipped()
                }
                .cornerRadius(20, corners: [.topLeft, .topRight])

                // TEXT INFO
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title.capitalized)
                        .font(.headline)
                        .foregroundColor(.black)
                        .lineLimit(2)

                    HStack(spacing: 16) {
                        // Example heart count
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                            Text(userService.currentUser?.likedRecipes.contains(recipe.id ?? "") == true
                                 ? "1" : "0")
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
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 5)
            .padding(.horizontal)
            .contentShape(Rectangle())
            .onTapGesture {
                navigate = true
            }

            // 3) Toggles Overlay
            VStack(spacing: 12) {
                // SAVE BUTTON
                Button {
                    userService.toggleSaveRecipe(recipeId: recipe.id ?? "")
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(radius: 2)
                        .overlay(
                            Image(systemName: userService.currentUser?.savedRecipes.contains(recipe.id ?? "") == true
                                  ? "bookmark.fill" : "bookmark")
                                .foregroundColor(
                                    userService.currentUser?.savedRecipes.contains(recipe.id ?? "") == true
                                    ? .yellow : .gray
                                )
                        )
                }

                // LIKE BUTTON
                Button {
                    userService.toggleLikeRecipe(recipeId: recipe.id ?? "")
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(radius: 2)
                        .overlay(
                            Image(systemName: userService.currentUser?.likedRecipes.contains(recipe.id ?? "") == true
                                  ? "heart.fill" : "heart")
                                .foregroundColor(
                                    userService.currentUser?.likedRecipes.contains(recipe.id ?? "") == true
                                    ? .red : .gray
                                )
                        )
                }
            }
            .padding(.trailing, 26)
            .padding(.bottom, 12)
            .contentShape(Rectangle())
            .zIndex(1)
        }
    }
}


#Preview {
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
        ratings: [],
        review: [],
        servings: 2,
        createdAt: Date(),
        isPublished: true
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

    return RecipeCard(recipe: sampleRecipe)
        .environmentObject(mockUserService)
}
