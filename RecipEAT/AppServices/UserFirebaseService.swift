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
                               imageUrl: "defaultAvatar",  // temporary value; will be updated below
                               password: hashedPassword,
                               createdAt: Date())
            
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
              let imageData = image.jpegData(compressionQuality: 0.8) else {
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
                                   createdAt: Date())
            
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
}
