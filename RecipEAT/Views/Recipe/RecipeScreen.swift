// RecipeScreen.swift

import SwiftUI

struct RecipeScreen: View {
    let recipes: [Recipe]
    var isMyRecipes: Bool = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(recipes) { recipe in
                    NavigationLink(value: RecipeWrapper(recipe: recipe, isMyRecipe: isMyRecipes)) {
                        RecipeCard(recipe: recipe)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}
