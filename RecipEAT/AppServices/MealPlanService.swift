//
//  MealPlanService.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class MealPlanService: ObservableObject {
    private let db = Firestore.firestore()
    
    func fetchMealPlan(for userId: String, weekStart: Date, completion: @escaping (MealPlan?, Error?) -> Void) {
        let docId = "\(userId)_\(weekStart.timeIntervalSince1970)"
        let planRef = db.collection("mealPlans").document(docId)
        
        planRef.getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            if let snapshot = snapshot, snapshot.exists {
                // Decode existing plan
                do {
                    let plan = try snapshot.data(as: MealPlan.self)
                    completion(plan, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                // Create a new plan
                let endDate = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
                let newPlan = MealPlan(
                    id: docId,
                    userId: userId,
                    startDate: weekStart,
                    endDate: endDate,
                    meals: [],
                    createdAt: Date()
                )
                do {
                    try planRef.setData(from: newPlan) { err in
                        if let err = err {
                            completion(nil, err)
                        } else {
                            completion(newPlan, nil)
                        }
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    
    func addMeal(to planId: String, meal: Meal, completion: @escaping (Bool, Error?) -> Void) {
        let docRef = db.collection("mealPlans").document(planId)
        do {
            // Use the same encoding approach for consistency.
            let mealData = try Firestore.Encoder().encode(meal)
            docRef.updateData([
                "meals": FieldValue.arrayUnion([mealData])
            ]) { error in
                completion(error == nil, error)
            }
        } catch {
            completion(false, error)
        }
    }
    
    // Search Recipes by Name Prefix
    func searchRecipes(prefix: String, completion: @escaping ([Recipe], Error?) -> Void) {
        db.collection("recipes")
            .whereField("isPublished", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion([], error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                // Case-insensitive search: match prefix in title or description
                let matchedRecipes = documents.compactMap { doc -> Recipe? in
                    let recipe = try? doc.data(as: Recipe.self)
                    if let recipe = recipe {
                        if recipe.title.lowercased().contains(prefix.lowercased()) ||
                            recipe.description.lowercased().contains(prefix.lowercased()) {
                            return recipe
                        }
                    }
                    return nil
                }
                
                completion(matchedRecipes, nil)
            }
    }
    
    func deleteMeal(from planId: String, meal: Meal, completion: @escaping (Bool, Error?) -> Void) {
        let planRef = db.collection("mealPlans").document(planId)
        do {
            let mealData = try Firestore.Encoder().encode(meal)
            planRef.updateData([
                "meals": FieldValue.arrayRemove([mealData])
            ]) { error in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        } catch {
            completion(false, error)
        }
    }

}
