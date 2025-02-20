//
//  SignupView.swift
//  RecipEAT
//
//  Created by user269332 on 2/19/25.
//

import SwiftUI
import RiveRuntime

struct SignupView: View {
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State var signupError = ""
    @State private var navigateToSignin = false
    @Binding var showModal: Bool
    @EnvironmentObject var userService: UserFirebaseService
    
    let check = RiveViewModel(fileName: "check", stateMachineName: "State Machine 1")
    let confetti = RiveViewModel(fileName: "confetti", stateMachineName: "State Machine 1")
    
    // Sign up function with animation feedback
    func signUp() {
          guard password == confirmPassword else {
              signupError = "Passwords do not match"
              return
          }
          
          isLoading = true
          userService.createUser(displayName: displayName, email: email, password: password) { success, error in
              DispatchQueue.main.async {
                  if success {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                          isLoading = false
                          withAnimation {
                              showModal = false
                              navigateToSignin = true
                          }
                      }
                  } else {
                      signupError = error ?? "Sign-up failed"
                      isLoading = false
                  }
              }
          }
      }
      
        
        var body: some View {
            VStack(spacing: 24) {
                Text("Sign Up")
                    .customFont(.largeTitle)
                Text("Create an account to access exclusive content.")
                    .customFont(.headline)
                
                VStack(alignment: .leading) {
                    Text("Username")
                        .customFont(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Enter your username", text: $displayName)
                        .customAuthTextField()
                }
                
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
                
                VStack(alignment: .leading) {
                    Text("Confirm Password")
                        .customFont(.subheadline)
                        .foregroundColor(.secondary)
                    SecureField("Confirm your password", text: $confirmPassword)
                        .customAuthTextField(image: Image("Icon Lock"))
                }
                
                if !signupError.isEmpty {
                    Text(signupError)
                        .foregroundColor(.red)
                        .customFont(.subheadline)
                }
                
                Button {
                    signUp()
                } label: {
                    Label("Sign Up", systemImage: "arrow.right")
                        .customFont(.headline)
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "F77D8E"))
                        .foregroundColor(.white)
                        .cornerRadius(20, corners: [.topRight, .bottomLeft, .bottomRight])
                        .cornerRadius(8, corners: [.topLeft])
                        .shadow(color: Color(hex: "F77D8E").opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .fullScreenCover(
                    isPresented: $navigateToSignin) {
                        SignInView(showModal: .constant(true))
                    }
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
    SignupView(showModal: .constant(true))
}
