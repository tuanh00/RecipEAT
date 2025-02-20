//
//  RecipeModel.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import Foundation
import FirebaseFirestore

struct Recipe: Identifiable, Codable {
    @DocumentID var id: String?
    var recipeId: String
    var imageUrl: String
    var title: String
    var description: String
    //var ingredients: [name: String, quantity: String, unit: String]
    var ingredients: [Ingredients]
    var steps: [String]
    var userId: String
    var category: String
    var ratings: [String]
    var review: [String]
    var createdAt: Date
}

struct Ingredients: Codable {
    var name: String
    var quantity: String
    var unit: String
}
