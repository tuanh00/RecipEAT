//
//  UserModel.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var imageUrl: String
    var password: String
    var createdAt: Date
    var savedRecipes: [String]
    var likedRecipes: [String]
}
