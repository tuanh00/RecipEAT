import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

class AuthenticationView: ObservableObject {
    @Published var isLoginSuccessed = false
    @Published var isLoading = false
    var userService: UserFirebaseService?
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Request additional scopes for profile and email info.
        GIDSignIn.sharedInstance.signIn(withPresenting: Application_utility.rootViewController,
                                        hint: nil,
                                        additionalScopes: ["profile", "email"]) { result, error in
            if let error = error {
                print("Google sign‑in error: \(error.localizedDescription)")
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            guard let result = result else {
                print("Google sign‑in: no result")
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            let googleUser = result.user
            // Extract token strings
            guard let idTokenString = googleUser.idToken?.tokenString, !idTokenString.isEmpty else {
                print("Missing idToken")
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            let accessTokenString = googleUser.accessToken.tokenString
            guard !accessTokenString.isEmpty else {
                print("Missing accessToken")
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idTokenString,
                                                           accessToken: accessTokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign‑in error: \(error.localizedDescription)")
                    DispatchQueue.main.async { self.isLoading = false }
                    return
                }
                guard let firebaseUser = authResult?.user else {
                    DispatchQueue.main.async { self.isLoading = false }
                    return
                }
                print("Firebase user: \(firebaseUser)")
                
                // Immediately update UI and dismiss the sign‑in view.
                DispatchQueue.main.async {
                                  self.isLoginSuccessed = true
                                  NotificationCenter.default.post(name: Notification.Name("GoToHomeTab"), object: nil)
                                  self.isLoading = false
                              }
                
                // Fetch or create Firestore user data in the background.
                let userDoc = Firestore.firestore().collection("users").document(firebaseUser.uid)
                userDoc.getDocument { snapshot, error in
                    if let error = error {
                        print("Error fetching user document: \(error.localizedDescription)")
                        return
                    }
                    if let snapshot = snapshot, snapshot.exists,
                       let userData = try? snapshot.data(as: User.self) {
                        print("Fetched user data: \(userData)")
                        DispatchQueue.main.async {
                            self.userService?.currentUser = userData
//                            self.isLoginSuccessed = true
//                            NotificationCenter.default.post(name: Notification.Name("GoToHomeTab"), object: nil)
                        }
                    } else {
                        // No document exists, so create one using Google profile info.
                        let displayName = googleUser.profile?.name ?? firebaseUser.displayName ?? "No Name"
                        let imageUrl = googleUser.profile?.imageURL(withDimension: 200)?.absoluteString ?? "defaultAvatar"
                        let newUser = User(id: firebaseUser.uid,
                                           email: firebaseUser.email ?? "",
                                           displayName: displayName,
                                           imageUrl: imageUrl,
                                           password: "",  // No need to save password for Gmail sign‑in.
                                           createdAt: Date(),
                                           savedRecipes: [],
                                           likedRecipes: [])
                        do {
                            try Firestore.firestore().collection("users").document(firebaseUser.uid).setData(from: newUser) { err in
                                if let err = err {
                                    print("Error creating user document: \(err.localizedDescription)")
                                } else {
                                    print("Created new user document for Gmail user.")
                                    DispatchQueue.main.async {
                                        self.userService?.currentUser = newUser
//                                        self.isLoginSuccessed = true
                                    }
                                }
                            }
                        } catch {
                            print("Error encoding user data: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}

