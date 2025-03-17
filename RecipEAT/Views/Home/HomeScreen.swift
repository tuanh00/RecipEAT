//
//  HomeScreen.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var userService: UserFirebaseService
    @StateObject var recipeService = RecipeService()
    @State private var allRecipes: [Recipe] = []

    var body: some View {
        NavigationStack {
//            VStack {
//                Button(action: {
//                    Task {
//                        do {
//                            try await userService.logout()
//                        } catch {
//                            print("Error during logout: \(error.localizedDescription)")
//                        }
//                    }
//                }) {
//                    Text("Log Out")
//                        .font(.headline)
//                        .foregroundColor(.blue)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.blue, lineWidth: 1)
//                        )
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 20)
//            }
            VStack {
                if allRecipes.isEmpty {
                    Text("No published recipes yet.")
                        .foregroundColor(.gray)
                        .padding(.top, 60)
                } else {
                    RecipeScreen(recipes: allRecipes.sorted(by: { $0.createdAt > $1.createdAt }))
                }
            }
            .navigationTitle("Recipes")
            .onAppear {
                recipeService.fetchPublishedRecipes { recipes in
                    self.allRecipes = recipes
                    print("[HomeScreen] Fetched \(recipes.count) published recipes")
                }
            }
        }
    }
}
