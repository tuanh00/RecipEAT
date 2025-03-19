//
//  SignInView.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-17.
//

import SwiftUI
import RiveRuntime
import FirebaseAuth
import FirebaseFirestore

struct SignInView: View {
    @State var email = ""
    @State var password = ""
    @State var isLoading = false
    @State var loginError = ""
    @Binding var showModal: Bool
    @StateObject var authVM = AuthenticationView()  // for Google sign‑in
    @State private var showSignup = false  // Controls SignupView presentation
    @EnvironmentObject var userService: UserFirebaseService
    
    let check = RiveViewModel(fileName: "check", stateMachineName: "State Machine 1")
    
    // Email/Password sign in
    func logInWithEmail() {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    loginError = error.localizedDescription
                    isLoading = false
                }
                return
            }
            guard let firebaseUser = authResult?.user else { return }
            let userDoc = Firestore.firestore().collection("users").document(firebaseUser.uid)
            userDoc.getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching user document: \(error.localizedDescription)")
                } else if let snapshot = snapshot, snapshot.exists,
                          let userData = try? snapshot.data(as: User.self) {
                    DispatchQueue.main.async {
                        self.userService.currentUser = userData
                    }
                }
                DispatchQueue.main.async {
                    if let _ = self.userService.currentUser {
                        print("User data loaded, closing SignInView.")
                        withAnimation {
                            NotificationCenter.default.post(name: Notification.Name("GoToHomeTab"), object: nil)
                            showModal = false
                        }
                    }
                    isLoading = false
                }
            }
        }
    }
    
    // Google sign in button action.
    func signInWithGoogle() {
        authVM.signInWithGoogle()
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Sign In")
                .customFont(.largeTitle)
            
            VStack(alignment: .leading) {
                Text("Email")
                    .customFont(.subheadline)
                    .foregroundColor(.secondary)
                AuthTextField(text: $email,
                              placeholder: "Enter your email",
                              icon: UIImage(named: "Icon Email"))
                .frame(height: 50)
                .keyboardType(.emailAddress)
            }
            
            VStack(alignment: .leading) {
                Text("Password")
                    .customFont(.subheadline)
                    .foregroundColor(.secondary)
                AuthTextField(text: $password,
                              placeholder: "Enter your password",
                              icon: UIImage(named: "Icon Lock"),
                              isSecure: true)
                .frame(height: 50)
            }
            
            if !loginError.isEmpty {
                Text(loginError)
                    .foregroundColor(.red)
                    .customFont(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Button {
                logInWithEmail()
            } label: {
                Label("Sign In", systemImage: "arrow.right")
                    .customFont(.headline)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "F77D8E"))
                    .foregroundColor(.white)
                    .cornerRadius(20, corners: [.topRight, .bottomLeft, .bottomRight])
                    .cornerRadius(8, corners: [.topLeft])
                    .shadow(color: Color(hex: "F77D8E").opacity(0.5), radius: 20, x: 0, y: 10)
            }
            
            // "Create Account" button
            Button {
                showSignup = true
            } label: {
                Text("Create Account")
                    .customFont(.subheadline)
                    .foregroundColor(Color(hex: "F77D8E"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            .fullScreenCover(isPresented: $showSignup) {
                SignupView(showModal: $showSignup)
            }
            
            // Google sign in icon/button:
            Button(action: {
                signInWithGoogle()
            }) {
                Image("Logo Google")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            .padding(.top, 20)
            
        }
        .padding(30)
        .background(.regularMaterial)
        .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
        .shadow(color: Color("Shadow").opacity(0.3), radius: 30, x: 0, y: 30)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.linearGradient(colors: [.white.opacity(0.8), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing))
        )
        .padding()
        .overlay(
            ZStack {
                if isLoading {
                    check.view()
                        .frame(width: 100, height: 100)
                        .allowsHitTesting(false)
                }
            }
        )
        .onAppear {
            authVM.userService = userService
        }
        .onReceive(authVM.$isLoginSuccessed) {
            success in
            if success {
                withAnimation {
                    showModal = false
                }
            }
        }
    }
}

#Preview {
    SignInView(showModal: .constant(true))
}
