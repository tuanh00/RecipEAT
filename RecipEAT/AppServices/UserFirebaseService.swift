//
//  UserFirebaseService.swift
//  RecipEAT
//
//  Created by user269332 on 2/19/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class UserFirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var currentUser: User?
    //@Published var loginError: String?
    
    func createUser(displayName: String, email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
        if let error = error {
            completion(false, "Error creating user: \(error.localizedDescription)")
            return
        }
                
        guard let user = result?.user else {
            completion(false, "User creation failed")
            return
        }
                
        let userData = User(id: user.uid, email: email, displayName: displayName, imageUrl: "defaultAvatar")
                
        do {
            try self.db.collection("users").document(user.uid).setData(from: userData) { err in
                if let err = err {
                    completion(false, "Error saving user data: \(err.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.currentUser = userData
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
