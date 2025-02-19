//
//  RecipeCard.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import SwiftUI

// sample data
let recipePosts: Recipe = Recipe(
    id: "0",
    recipeId: "0",
    imageUrl: "leche-flan",
    title: "Leche Flan",
    description: "Leche Flan is a dessert made-up of eggs and milk with a soft caramel on top. It resembles crème caramel and caramel custard.",
    ingredients: [
        Ingredients(name: "Eggs", quantity: "10", unit: "pieces"),
        Ingredients(name: "Condensed Milk", quantity: "1", unit: "can (14 oz)"),
        Ingredients(name: "Fresh Milk or Evaporated Milk", quantity: "1", unit: "cup"),
        Ingredients(name: "Granulated Sugar", quantity: "1", unit: "cup"),
        Ingredients(name: "Vanilla Extract", quantity: "1", unit: "teaspoon")
    ],
    steps: [
        "Using all the eggs, separate the yolk from the egg white (only egg yolks will be used).",
        "Place the egg yolks in a big bowl then beat them using a fork or an egg beater",
        "Add the condensed milk and mix thoroughly",
        "Pour-in the fresh milk and Vanilla. Mix well",
        "Put the mold (llanera) on top of the stove and heat using low fire",
        "Put-in the granulated sugar on the mold and mix thoroughly until the solid sugar turns into liquid (caramel) having a light brown color. Note: Sometimes it is hard to find a Llanera (Traditional flan mold) depending on your location. I find it more convenient to use individual Round Pans in making leche flan.",
        "Spread the caramel (liquid sugar) evenly on the flat side of the mold",
        "Wait for 5 minutes then pour the egg yolk and milk mixture on the mold",
        "Cover the top of the mold using an Aluminum foil",
        "Steam the mold with egg and milk mixture for 30 to 35 minutes.",
        "After steaming, let the temperature cool down then refrigerate",
        "Serve for dessert. Share and Enjoy!",
    ],
    userId: "0",
    category: "Dessert",
    ratings: ["4.5", "4.7", "4.3"],
    review: ["Not too sweet, just right.", "The texture is amazing!"],
    createdAt: Date()
)

struct RecipeCard: View {
    let recipe: Recipe
    
    // track recipe save status
    @State private var isSaved = false
    
    var body: some View {
        VStack {
            Text(recipe.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Image(recipe.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(recipe.description)
                .padding()
            
            HStack {
                //Image(systemName: "bookmark")
                Button(action: {
                    //print("Recipe saved.")
                    isSaved.toggle()
                }) {
                    HStack {
                        //Image(systemName: "bookmark")
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        //Text("Save")
                        Text(isSaved ? "Saved" : "Save")
                    }
                    .padding(5)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                }
                Spacer()
                
                Button(action: {
                    
                }) {
                    HStack {
                        Image(systemName: "ellipsis")
                        Text("More")
                    }
                    .padding(5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                }
            }.padding(.horizontal)
        }
    }
}

#Preview {
    RecipeCard(recipe: recipePosts)
}
