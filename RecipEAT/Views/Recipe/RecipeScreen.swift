//
//  RecipeScreen.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-03-16.
//

import SwiftUI

struct RecipeScreen: View {
    let recipes: [Recipe]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(recipes) { recipe in
                        RecipeCard(recipe: recipe)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationDestination(for: Recipe.self) {
            recipe in
            RecipeDetails(recipe: recipe)
        }
    }
}

//#Preview {
//    RecipeScreen()
//}
