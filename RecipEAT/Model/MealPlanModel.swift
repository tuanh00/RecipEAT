//
//  MealPlanModel.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import Foundation

struct MealPlan: Identifiable, Codable {
    var id: String?
    var userId: String
    // var meals: [recipeId: String, date: Date]
    var meals: [Meals]
    var createdAt: Date
}

struct Meals: Codable {
    var recipeId: String
    var date: Date
}
