import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

class AuthenticationView: ObservableObject {
    @Published var isLoginSuccessed = false
    var userService: UserFirebaseService?  // to be set from the environment
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Request additional scopes for profile and email info.
        GIDSignIn.sharedInstance.signIn(withPresenting: Application_utility.rootViewController,
                                        hint: nil,
                                        additionalScopes: ["profile", "email"]) { result, error in
            if let error = error {
                print("Google sign‑in error: \(error.localizedDescription)")
                return
            }
            guard let result = result else {
                print("Google sign‑in: no result")
                return
            }
            let googleUser = result.user
            // Extract token strings
            guard let idTokenString = googleUser.idToken?.tokenString, !idTokenString.isEmpty else {
                print("Missing idToken")
                return
            }
            let accessTokenString = googleUser.accessToken.tokenString
            guard !accessTokenString.isEmpty else {
                print("Missing accessToken")
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idTokenString,
                                                           accessToken: accessTokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign‑in error: \(error.localizedDescription)")
                    return
                }
                guard let firebaseUser = authResult?.user else { return }
                print("Firebase user: \(firebaseUser)")
                // Now check Firestore for this user's data.
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
                        }
                    } else {
                        // No document exists, so create one using Google profile info.
                        let displayName = googleUser.profile?.name ?? firebaseUser.displayName ?? "No Name"
                        let imageUrl = googleUser.profile?.imageURL(withDimension: 200)?.absoluteString ?? "defaultAvatar"
                        let newUser = User(id: firebaseUser.uid,
                                           email: firebaseUser.email ?? "",
                                           displayName: displayName,
                                           imageUrl: imageUrl,
                                           password: "",  // No password for Gmail sign‑in.
                                           createdAt: Date())
                        do {
                            try Firestore.firestore().collection("users").document(firebaseUser.uid).setData(from: newUser) { err in
                                if let err = err {
                                    print("Error creating user document: \(err.localizedDescription)")
                                } else {
                                    print("Created new user document for Gmail user.")
                                    DispatchQueue.main.async {
                                        self.userService?.currentUser = newUser
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
    
    func logout() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
        userService?.currentUser = nil
    }
}

