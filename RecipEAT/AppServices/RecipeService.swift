//
//  RecipeFirebaseService.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-23.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine
import UIKit  // for UIImage if needed

class RecipeService: ObservableObject {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // 1) Create a new recipe in Firestore
    func createRecipe(recipe: Recipe, image: UIImage?, completion: @escaping (Bool, String?) -> Void) {
        // If you have an image to upload:
        if let image = image {
            uploadRecipeImage(image: image) { [weak self] result in
                switch result {
                case .success(let imageUrl):
                    // Create a copy of recipe with updated `imageUrl`
                    var newRecipe = recipe
                    newRecipe.imageUrl = imageUrl
                    self?.saveRecipeToFirestore(newRecipe, completion: completion)
                    
                case .failure(let error):
                    completion(false, "Failed to upload image: \(error.localizedDescription)")
                }
            }
        } else {
            // No image? Save recipe as is.
            saveRecipeToFirestore(recipe, completion: completion)
        }
    }
    
    func publishRecipe(title: String,
                       description: String,
                       ingredients: [Ingredients],
                       instructions: [String],
                       servings: Int,
                       category: String,
                       image: UIImage?,
                       isPublished: Bool,
                       completion: @escaping (Bool, String?) -> Void) {
        let lowerTitle = title.lowercased()
        let lowerDesc = description.lowercased()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(false, "User not logged in.")
            return
        }
        
        let recipe = Recipe(imageUrl: "", title: lowerTitle, description: lowerDesc, ingredients: ingredients, instructions: instructions, userId: currentUserId, category: category, ratings: [], review: [], servings: servings, createdAt: Date(), isPublished: isPublished)
        createRecipe(recipe: recipe, image: image, completion: completion)
    }
    // 2) Upload recipe image to Firebase Storage
    private func uploadRecipeImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageEncoding", code: -1, userInfo: nil)))
            return
        }
        let uniqueFileName = UUID().uuidString + ".jpg"
        let storageRef = storage.reference().child("recipes/\(uniqueFileName)")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let urlString = url?.absoluteString {
                    completion(.success(urlString))
                }
            }
        }
    }
    
    // 3) Save recipe document to Firestore
    private func saveRecipeToFirestore(_ recipe: Recipe, completion: @escaping (Bool, String?) -> Void) {
        do {
            let docRef = db.collection("recipes").document()
            var mutableRecipe = recipe
            mutableRecipe.id = docRef.documentID
            mutableRecipe.createdAt = Date()
            
            try docRef.setData(from: mutableRecipe) { error in
                if let error = error {
                    completion(false, "Failed to save recipe: \(error.localizedDescription)")
                } else {
                    completion(true, nil)
                }
            }
        } catch {
            completion(false, "Failed to encode recipe: \(error.localizedDescription)")
        }
    }
    
    // 4) Delete an existing recipe
    func deleteRecipe(recipeId: String, completion: @escaping (Bool, String?) -> Void) {
        db.collection("recipes").document(recipeId).delete { error in
            if let error = error {
                completion(false, "Failed to delete recipe: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }
    
    //Searches recipes whose title OR description starts with a given prefix
    func searchRecipes(prefix: String, completion: @escaping ([Recipe], Error?) -> Void) {
        let lowerPrefix = prefix.lowercased()
        let collection = db.collection("recipes")
        var results: [Recipe] = []
        var errors: [Error] = []
        
        let group = DispatchGroup()
        
        // 1) Query for matching titles (case-insensitive)
        group.enter()
        collection
            .whereField("title", isGreaterThanOrEqualTo: lowerPrefix)
            .whereField("title", isLessThan: lowerPrefix + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    errors.append(error)
                } else if let snapshot = snapshot {
                    let found = snapshot.documents.compactMap { doc in
                        try? doc.data(as: Recipe.self)
                    }
                    results.append(contentsOf: found)
                }
                group.leave()
            }
        
        // 2) Query for matching descriptions (case-insensitive)
        group.enter()
        collection
            .whereField("description", isGreaterThanOrEqualTo: lowerPrefix)
            .whereField("description", isLessThan: lowerPrefix + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    errors.append(error)
                } else if let snapshot = snapshot {
                    let found = snapshot.documents.compactMap { doc in
                        try? doc.data(as: Recipe.self)
                    }
                    results.append(contentsOf: found)
                }
                group.leave()
            }
        
        // Combine results once both queries finish
        group.notify(queue: .main) {
            let uniqueResults = Dictionary(grouping: results, by: \.id)
                .compactMap { $0.value.first }
            if let firstError = errors.first {
                completion(Array(uniqueResults), firstError)
            } else {
                completion(Array(uniqueResults), nil)
            }
        }
    }
}


