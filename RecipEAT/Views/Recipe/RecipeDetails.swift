//
//  RecipeDetails.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-03-16.
//

import SwiftUI

struct RecipeDetails: View {
    let recipe: Recipe
    let isMyRecipe: Bool

    @EnvironmentObject var recipeService: RecipeService
    @Environment(\.dismiss) var dismiss  // Added dismiss environment variable
    @State private var latestRecipe: Recipe?
    @State private var navigateToUpdate = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                AsyncImage(url: URL(string: latestRecipe?.imageUrl ?? recipe.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 250)
                .clipped()
                .cornerRadius(12)

                Text((latestRecipe?.title ?? recipe.title).capitalized)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text((latestRecipe?.description ?? recipe.description).capitalized)
                    .font(.body)

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                        Text("\(latestRecipe?.servings ?? recipe.servings) servings")
                    }
                    .foregroundColor(.green)

                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                        Text("\(latestRecipe?.likeCount ?? recipe.likeCount)")
                    }
                    .foregroundColor(.red)

                    HStack(spacing: 4) {
                        Image(systemName: "bookmark.fill")
                        Text("\(latestRecipe?.saveCount ?? recipe.saveCount)")
                    }
                    .foregroundColor(.yellow)
                }
                .font(.subheadline)

                Divider()

                Text("Ingredients")
                    .font(.title2)
                    .fontWeight(.semibold)

                // CHANGED: Using the enumerated offset as the unique ID instead of the ingredient name
                ForEach(Array((latestRecipe?.ingredients ?? recipe.ingredients).enumerated()), id: \.offset) { index, ingredient in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                        Text("\(ingredient.name) - \(ingredient.quantity) \(ingredient.unit)")
                    }
                    .padding(.vertical, 2)
                }

                Divider()

                Text("Instructions")
                    .font(.title2)
                    .fontWeight(.semibold)

                ForEach(Array((latestRecipe?.instructions ?? recipe.instructions).enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top) {
                        Text("\(index + 1).").bold()
                        Text(step)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isMyRecipe {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        navigateToUpdate = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToUpdate) {
            UpdateRecipeScreen(recipe: latestRecipe ?? recipe)
        }
        .onAppear {
            fetchLatestRecipe()
        }
    }

    /// Modified fetch method:
    /// If the recipe is not found (deleted), dismiss this view.
    private func fetchLatestRecipe() {
        guard let recipeId = recipe.id else { return }
        recipeService.fetchRecipeById(recipeId) { updated in
            DispatchQueue.main.async {
                if let updated = updated {
                    latestRecipe = updated
                } else {
                    // Recipe not found—likely deleted—so dismiss this view.
                    dismiss()
                }
            }
        }
    }
}
