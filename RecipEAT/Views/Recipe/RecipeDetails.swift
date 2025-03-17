//
//  RecipeDetails.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-03-16.
//

import SwiftUI

struct RecipeDetails: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                AsyncImage(url: URL(string: recipe.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 250)
                .clipped()
                .cornerRadius(12)

                // Title
                Text(recipe.title.capitalized)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Servings
                HStack {
                    Image(systemName: "person.2.fill")
                    Text("\(recipe.servings) servings")
                }
                .foregroundColor(.gray)
                .font(.subheadline)

                Divider()

                // Ingredients
                Text("Ingredients")
                    .font(.title2)
                    .fontWeight(.semibold)

                ForEach(recipe.ingredients, id: \.name) { ingredient in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                        Text("\(ingredient.name) - \(ingredient.quantity) \(ingredient.unit)")
                    }
                    .padding(.vertical, 2)
                }

                Divider()

                // Instructions
                Text("Instructions")
                    .font(.title2)
                    .fontWeight(.semibold)

                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top) {
                        Text("\(index + 1).")
                            .bold()
                        Text(step)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RecipeDetails(
        recipe: Recipe(
            id: "sample1",
            imageUrl: "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?q=80&w=2080&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            title: "Creamy Tomato Pasta",
            description: "A creamy delicious tomato-based pasta perfect for quick dinner.",
            ingredients: [
                Ingredients(name: "Tomato", quantity: "2", unit: "units"),
                Ingredients(name: "Cream", quantity: "200", unit: "grams"),
                Ingredients(name: "Pasta", quantity: "1", unit: "pack")
            ],
            instructions: ["Boil pasta", "Prepare sauce", "Mix and serve"],
            userId: "ClCmQWjsj4ZuGqLnzDyxM8EbFj83",
            category: "Dinner",
            ratings: ["123"],
            review: ["Ok"],
            servings: 2,
            createdAt: Date.now,
            isPublished: true
        )
    )
}
