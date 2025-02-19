//
//  SignInView.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-17.
//

import SwiftUI
import RiveRuntime
import FirebaseAuth

struct SignInView: View {
    @State var email = ""
    @State var password = ""
    @State var isLoading = false
    @State var loginError = ""
    @Binding var showModal: Bool
    @StateObject var authVM = AuthenticationView()  // for Google sign‑in
    
    let check = RiveViewModel(fileName: "check", stateMachineName: "State Machine 1")
    let confetti = RiveViewModel(fileName: "confetti", stateMachineName: "State Machine 1")
    
    // Email/Password sign in with animation feedback
    func logInWithEmail() {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    loginError = error.localizedDescription
                    check.triggerInput("Error")
                    isLoading = false
                }
                return
            }
            // On success, trigger animation then dismiss the view.
            DispatchQueue.main.async {
                check.triggerInput("Reset")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    check.triggerInput("Check")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    confetti.triggerInput("Trigger explosion")
                    isLoading = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation {
                        showModal = false
                    }
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
            Text("Access to exclusive content. Learn design and code.")
                .customFont(.headline)
            
            VStack(alignment: .leading) {
                Text("Email")
                    .customFont(.subheadline)
                    .foregroundColor(.secondary)
                TextField("Enter your email", text: $email)
                    .customAuthTextField()
            }
            
            VStack(alignment: .leading) {
                Text("Password")
                    .customFont(.subheadline)
                    .foregroundColor(.secondary)
                SecureField("Enter your password", text: $password)
                    .customAuthTextField(image: Image("Icon Lock"))
            }
            
            if !loginError.isEmpty {
                Text(loginError)
                    .foregroundColor(.red)
                    .customFont(.subheadline)
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
                confetti.view()
                    .scaleEffect(3)
                    .allowsHitTesting(false)
            }
        )
    }
}

#Preview {
    SignInView(showModal: .constant(true))
}
