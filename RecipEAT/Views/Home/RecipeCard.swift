//
//  RecipeCard.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import SwiftUI

struct RecipeCard: View {
//    let recipe: Recipe
//    
//    // track recipe save status
//    @State private var isSaved = false
    
    var body: some View {
        VStack {
            Text("Hello World")
        }
//        VStack(alignment: .leading, spacing: 20) {
//            // title and category
//            HStack {
//                Text(recipe.title)
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//
//                Text(recipe.category)
//                    .padding(5)
//                    .background(.dessert)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//
//            // image and description
//            Image(recipe.imageUrl)
//                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: .infinity)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .shadow(radius: 5)
//
//            Text(recipe.description)
//
//            HStack {
//                // save button
//                //Image(systemName: "bookmark")
//                Button(action: {
//                    //print("Recipe saved.")
//                    isSaved.toggle()
//                }) {
//                    HStack {
//                        //Image(systemName: "bookmark")
//                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
//                        //Text("Save")
//                        Text(isSaved ? "Saved" : "Save")
//                    }
//                    .padding(5)
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .cornerRadius(5)
//                }
//                Spacer()
//
//                // RecipeView button
//                NavigationLink(destination: RecipeView(recipe: recipe)) {
//                    HStack {
//                        Image(systemName: "ellipsis")
//                        Text("More")
//                    }
//                    .padding(5)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(5)
//
//                }
//            }
//        }
//        .padding()
    }
}

#Preview {
    NavigationStack {
//        RecipeCard(recipe: recipePosts)
        RecipeCard()
    }
}
