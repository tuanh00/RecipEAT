//
//  RecipeModel.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import Foundation
import FirebaseFirestore

struct Recipe: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var imageUrl: String
    var title: String
    var description: String
    var ingredients: [Ingredients]
    var instructions: [String]
    var userId: String
    var category: String
    var review: [String]
    var servings: Int
    var createdAt: Date
    var isPublished: Bool
    var likeCount: Int
    var saveCount: Int
}

struct Ingredients: Codable, Hashable {
    var name: String
    var quantity: String
    var unit: String
}
