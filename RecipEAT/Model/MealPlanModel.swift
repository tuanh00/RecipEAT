//
//  MealPlanModel.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import Foundation
import FirebaseFirestore

struct MealPlan: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var meals: [Meal] = []
    var createdAt: Date = Date()
}

struct Meal: Identifiable, Codable {
    var id: String = UUID().uuidString
    var recipeName: String = ""
    var date: Date = Date()
    var notes: String = ""
    var category: String = ""
}

