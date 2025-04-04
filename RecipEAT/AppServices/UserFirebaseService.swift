//
//  SignupView.swift
//  RecipEAT
//
//  Created by user269332 on 2/19/25.
//

import Foundation
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine

class UserFirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    @Published var currentUser: User?
    
    func createUser(displayName: String, email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, "Error creating user: \(error.localizedDescription)")
                return
            }
            
            guard let firebaseUser = result?.user else {
                completion(false, "User creation failed")
                return
            }
            
            // Simple "hashing" using Base64 encoding (for demonstration only)
            let hashedPassword = Data(password.utf8).base64EncodedString()
            
            // Create a preliminary user object using a temporary imageUrl value.
            var newUser = User(id: firebaseUser.uid,
                               email: email,
                               displayName: displayName,
                               imageUrl: "defaultAvatar",
                               password: hashedPassword,
                               createdAt: Date(),
                               savedRecipes:  [],
                               likedRecipes: [])
            
            // Upload the default avatar from Assets to Storage.
            self.uploadDefaultAvatar(for: firebaseUser) { downloadURL in
                if let downloadURL = downloadURL {
                    newUser.imageUrl = downloadURL
                } else {
                    // If upload fails, use a fallback URL or keep the asset name.
                    newUser.imageUrl = "fallbackDefaultAvatarURL"
                }
                
                do {
                    try self.db.collection("users").document(firebaseUser.uid).setData(from: newUser) { err in
                        if let err = err {
                            completion(false, "Error saving user data: \(err.localizedDescription)")
                        } else {
                            DispatchQueue.main.async {
                                self.currentUser = newUser
                            }
                            completion(true, nil)
                        }
                    }
                } catch {
                    completion(false, "Failed to encode user data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Uploads the default avatar image from the app’s assets to Firebase Storage.
    private func uploadDefaultAvatar(for user: FirebaseAuth.User, completion: @escaping (String?) -> Void) {
        guard let image = UIImage(named: "defaultAvatar"),
              let imageData = image.jpegDataCompressed(quality: 0.6, maxWidth: 1024) else {
            completion(nil)
            return
        }
        
        let storageRef = storage.reference().child("userAvatars/\(user.uid).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading default avatar: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                completion(url?.absoluteString)
            }
        }
    }
    
    /// For Gmail sign‑in: Create or update the Firestore user document using Google profile info.
    func createOrUpdateUserForGoogle(firebaseUser: FirebaseAuth.User,
                                     googleUser: GIDGoogleUser,
                                     completion: @escaping (Bool, String?) -> Void) {
        let userDoc = db.collection("users").document(firebaseUser.uid)
        userDoc.getDocument { snapshot, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            // Use Google profile info if available; fall back to FirebaseAuth data.
            let displayName = googleUser.profile?.name ?? firebaseUser.displayName ?? "No Name"
            let imageUrl = googleUser.profile?.imageURL(withDimension: 200)?.absoluteString ?? "defaultAvatar"
            
            // For Google sign‑in, password can be an empty string.
            let updatedUser = User(id: firebaseUser.uid,
                                   email: firebaseUser.email ?? "",
                                   displayName: displayName,
                                   imageUrl: imageUrl,
                                   password: "",
                                   createdAt: Date(),
                                   savedRecipes: [],
                                   likedRecipes: [])
            
            if let snapshot = snapshot, snapshot.exists {
                // Update the existing document.
                userDoc.updateData([
                    "displayName": displayName,
                    "imageUrl": imageUrl
                ]) { error in
                    if let error = error {
                        completion(false, error.localizedDescription)
                    } else {
                        DispatchQueue.main.async {
                            self.currentUser = updatedUser
                        }
                        completion(true, nil)
                    }
                }
            } else {
                // Create a new document.
                do {
                    try userDoc.setData(from: updatedUser) { err in
                        if let err = err {
                            completion(false, err.localizedDescription)
                        } else {
                            DispatchQueue.main.async {
                                self.currentUser = updatedUser
                            }
                            completion(true, nil)
                        }
                    }
                } catch {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func toggleSaveRecipe(recipeId: String){
        guard let userId = currentUser?.id else { return }
        let userDoc = db.collection("users").document(userId)
        let recipeDoc = db.collection("recipes").document(recipeId)
        
        var updatedSaved = currentUser?.savedRecipes ?? []
        let isSaved = updatedSaved.contains(recipeId)
        
        if isSaved {
            updatedSaved.removeAll { $0 == recipeId }
            recipeDoc.updateData(["saveCount": FieldValue.increment(Int64(-1))])
        } else {
            updatedSaved.append(recipeId)
            recipeDoc.updateData(["saveCount": FieldValue.increment(Int64(1))])
        }
        
        userDoc.updateData(["savedRecipes": updatedSaved]) {
            error in
            if error == nil {
                DispatchQueue.main.async {
                    self.currentUser?.savedRecipes = updatedSaved
                }
            }
        }
    }
    
    func toggleLikeRecipe(recipeId: String) {
        guard let userId = currentUser?.id else { return }
        let userDoc = db.collection("users").document(userId)
        let recipeDoc = db.collection("recipes").document(recipeId)
        
        var updatedLiked = currentUser?.likedRecipes ?? []
        let isLiked = updatedLiked.contains(recipeId)
        
        if isLiked {
            updatedLiked.removeAll { $0 == recipeId }
            recipeDoc.updateData(["likeCount": FieldValue.increment(Int64(-1))])
        } else {
            updatedLiked.append(recipeId)
            recipeDoc.updateData(["likeCount": FieldValue.increment(Int64(1))])
        }
        userDoc.updateData(["likedRecipes": updatedLiked]) {
            error in
            if error == nil {
                DispatchQueue.main.async {
                    self.currentUser?.likedRecipes = updatedLiked
                }
            }
        }
    }
    
    func logout() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
        await MainActor.run {
            self.currentUser = nil
        }
    }
    
    func updateProfile(displayName: String?, newPassword: String?, completion: @escaping (Error?) -> Void) {
        guard let user = self.currentUser, let userId = user.id else {
            completion(NSError(domain: "UserFirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No current user"]))
            return
        }
        var updates: [String: Any] = [:]
        if displayName != user.displayName {
            updates["displayName"] = displayName
        }
        if let newPassword = newPassword, !newPassword.isEmpty {
            guard newPassword.count >= 6 else {
                completion(NSError(domain: "UserFirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Password must be at least 6 characters long"]))
                return
            }
            
            let hashedPassword = Data(newPassword.utf8).base64EncodedString()
            updates["password"] = hashedPassword
            // Update FirebaseAuth password as well.
            Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                if let error = error {
                    print("Error updating Auth password: \(error.localizedDescription)")
                }
            }
        }
        if updates.isEmpty {
            completion(nil)
            return
        }
        let userDoc = db.collection("users").document(userId)
        userDoc.updateData(updates) { error in
            if let error = error {
                completion(error)
            } else {
                // Update local copy
                DispatchQueue.main.async {
                    self.currentUser?.displayName = displayName!
                }
                completion(nil)
            }
        }
    }
    
    func loadCurrentUser(completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(NSError(domain: "UserFirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]))
            return
        }
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.currentUser = nil
                    try? Auth.auth().signOut()
                }
                completion?(error)
            } else if let snapshot = snapshot, snapshot.exists,
                      let userData = try? snapshot.data(as: User.self) {
                DispatchQueue.main.async {
                    self.currentUser = userData
                }
                completion?(nil)
            } else {
                completion?(NSError(domain: "UserFirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"]))
            }
        }
    }
    
    /// New function: Update user's avatar image.
    func updateAvatar(image: UIImage, completion: @escaping (Bool, String?) -> Void) {
        guard let user = self.currentUser else {
            completion(false, "No current user")
            return
        }
        guard let imageData = image.jpegDataCompressed(quality: 0.6, maxWidth: 1024) else {
            completion(false, "Invalid image")
            return
        }
        
        // Safely unwrap user.id into userId
        guard let userId = user.id else {
            completion(false, "User ID is missing.")
            return
        }
        
        let storageRef = storage.reference().child("userAvatars/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading avatar: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                    return
                }
                guard let downloadURL = url?.absoluteString else {
                    completion(false, "Download URL not found")
                    return
                }
                
                // Update Firestore user document with new avatar URL.
                self.db.collection("users").document(userId).updateData([
                    "imageUrl": downloadURL
                ]) { error in
                    if let error = error {
                        print("Error updating user document: \(error.localizedDescription)")
                        completion(false, error.localizedDescription)
                    } else {
                        DispatchQueue.main.async {
                            self.currentUser?.imageUrl = downloadURL
                        }
                        completion(true, nil)
                    }
                }
            }
        }
    }
}
