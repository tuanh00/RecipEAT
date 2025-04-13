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
import UIKit

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
    
    // Publish New Recipe
    func publishRecipe(title: String, description: String, ingredients: [Ingredients], instructions: [String], servings: Int, category: String, image: UIImage?, isPublished: Bool, completion: @escaping (Bool, String?) -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, "User not logged in")
            return
        }

        let recipeRef = db.collection("recipes").document()
        
        func uploadData(imageUrl: String) {
            let data: [String: Any] = [
                "id": recipeRef.documentID,
                "title": title,
                "description": description,
                "ingredients": ingredients.map { ["name": $0.name, "quantity": $0.quantity, "unit": $0.unit] },
                "instructions": instructions,
                "servings": servings,
                "category": category,
                "imageUrl": imageUrl,
                "isPublished": isPublished,
                "userId": userId,
                "createdAt": FieldValue.serverTimestamp(),
                "likeCount": 0,
                "saveCount": 0,
                "review": []
            ]
            recipeRef.setData(data) { error in
                completion(error == nil, error?.localizedDescription)
            }
        }

        if let image = image {
            uploadRecipeImage(image: image) { result in
                switch result {
                case .success(let url): uploadData(imageUrl: url)
                case .failure(let error): completion(false, error.localizedDescription)
                }
            }
        } else {
            uploadData(imageUrl: "")
        }
    }
    
    // 2) Upload recipe image to Firebase Storage
    func uploadRecipeImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegDataCompressed(quality: 0.6, maxWidth: 1024) else {
            completion(.failure(NSError(domain: "ImageEncoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image compression failed."])))
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
    
    func deleteRecipe(recipeId: String, userId: String, completion: @escaping (Bool, String?) -> Void) {
        db.collection("recipes").document(recipeId).delete { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
    
    // 5) Searches recipes whose title OR description starts with a given prefix
    /// Search recipes where isPublished == true
    /// Search by title or description containing the query (case-insensitive)
    func searchRecipes(prefix: String, completion: @escaping ([Recipe], Error?) -> Void) {
        let lowercasedQuery = prefix.lowercased()

        db.collection("recipes")
            .whereField("isPublished", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion([], error)
                    return
                }

                let recipes = snapshot?.documents.compactMap { document -> Recipe? in
                    let data = document.data()
                    let title = (data["title"] as? String)?.lowercased() ?? ""
                    let description = (data["description"] as? String)?.lowercased() ?? ""

                    if title.contains(lowercasedQuery) || description.contains(lowercasedQuery) {
                        return try? document.data(as: Recipe.self)
                    }
                    return nil
                } ?? []

                completion(recipes, nil)
            }
    }

    // 6) Display recipes
    func fetchAllRecipes(completion: @escaping ([Recipe]) -> Void) {
        db.collection("recipes").getDocuments {
            snapshot, error in
            if let error = error {
                print("Error fetching recipes: \(error.localizedDescription)")
                completion([])
                return
            }
            let recipes = snapshot?.documents.compactMap {
                try? $0.data(as: Recipe.self)
            } ?? []
            completion(recipes)
        }
    }
    // 7) Fetch only published recipes
    func fetchPublishedRecipes(completion: @escaping ([Recipe]) -> Void) {
        db.collection("recipes")
            .whereField("isPublished", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .getDocuments {
                snapshot, error in
                if let error = error {
                    print("Error fetching published recipes: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let recipes = snapshot?.documents.compactMap {
                    document -> Recipe? in
                    try? document.data(as: Recipe.self)
                } ?? []
                
                DispatchQueue.main.async {
                    completion(recipes)
                }
            }
    }
    func filterRecipesBySavedList(allRecipes: [Recipe], savedIds: [String]) -> [Recipe] {
        allRecipes.filter { savedIds.contains($0.id ?? "") }
    }
    
    func filterRecipesByLikedList(allRecipes: [Recipe], likedIds: [String]) -> [Recipe] {
        allRecipes.filter { likedIds.contains($0.id ?? "") }
    }
    func fetchRecipeById(_ recipeId: String, completion: @escaping (Recipe?) -> Void) {
        db.collection("recipes").document(recipeId).getDocument {
            snapshot, error in
            if let error = error {
                print("Error fetching recipe \(recipeId): \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let snapshot = snapshot, snapshot.exists,
               let recipe = try? snapshot.data(as: Recipe.self) {
                completion(recipe)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchRecipesByCurrentUser(userId: String, completion: @escaping ([Recipe]) -> Void) {
        db.collection("recipes").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Fetch Error: \(error.localizedDescription)")
                completion([])
                return
            }
            let recipes = snapshot?.documents.compactMap { try? $0.data(as: Recipe.self) } ?? []
            completion(recipes)
        }
    }
    
    // Update Recipe
    func updateRecipe(recipeId: String, title: String, description: String, ingredients: [Ingredients], instructions: [String], servings: Int, isPublished: Bool, newImageUrl: String? = nil, completion: @escaping (Bool, String?) -> Void) {
        var updateData: [String: Any] = [
            "title": title,
            "description": description,
            "ingredients": ingredients.map { ["name": $0.name, "quantity": $0.quantity, "unit": $0.unit] },
            "instructions": instructions,
            "servings": servings,
            "isPublished": isPublished
        ]
        if let newImageUrl = newImageUrl {
            updateData["imageUrl"] = newImageUrl
        }
        
        db.collection("recipes").document(recipeId).updateData(updateData) { error in
            completion(error == nil, error?.localizedDescription)
        }
    }
}


