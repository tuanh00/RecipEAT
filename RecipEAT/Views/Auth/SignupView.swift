import SwiftUI
import RiveRuntime

enum SignupField: Hashable {
    case username, email, password, confirmPassword
}

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
    @FocusState private var focusedField: SignupField?
    
    let check = RiveViewModel(fileName: "check", stateMachineName: "State Machine 1")
    let confetti = RiveViewModel(fileName: "confetti", stateMachineName: "State Machine 1")
    
    // Email format checker
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
    
    // Sign up function with animation feedback
    func signUp() {
        signupError = ""
        if displayName.trimmingCharacters(in: .whitespaces).isEmpty {
            signupError = "Username cannot be empty."
            focusedField = .username
            return
        }
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            signupError = "Email cannot be empty."
            focusedField = .email
            return
        }
        if !isValidEmail(email) {
            signupError = "Please enter a valid email format."
            focusedField = .email
            return
        }
        if password.isEmpty {
            signupError = "Password cannot be empty."
            focusedField = .password
            return
        }
        if confirmPassword.isEmpty {
            signupError = "Please confirm your password."
            focusedField = .confirmPassword
            return
        }
        if password != confirmPassword {
            signupError = "Passwords do not match."
            focusedField = .confirmPassword
            return
        }
        
        isLoading = true
        userService.createUser(displayName: displayName, email: email, password: password) { success, error in
            DispatchQueue.main.async {
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        check.triggerInput("Check")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        confetti.triggerInput("Trigger explosion")
                        withAnimation {
                            isLoading = false
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation {
                            showModal = false //close itself after success
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
        ZStack {
            Color.clear
                .ignoresSafeArea(.keyboard, edges: .bottom)
            
            VStack {
                Spacer(minLength: 0)
                VStack(spacing: 24) {
                    Text("Sign Up")
                        .customFont(.largeTitle)
                    Text("Create an account to access exclusive content.")
                        .customFont(.headline)
                    
                    VStack(alignment: .leading) {
                        Text("Username")
                            .customFont(.subheadline)
                            .foregroundColor(.secondary)
                        AuthTextField(text: $displayName,
                                      placeholder: "Enter your username",
                                      icon: UIImage(named: "Icon Email"))
                            .frame(height: 50)
                            .focused($focusedField, equals: .username)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Email")
                            .customFont(.subheadline)
                            .foregroundColor(.secondary)
                        AuthTextField(text: $email,
                                      placeholder: "Enter your email",
                                      icon: UIImage(named: "Icon Email"))
                            .frame(height: 50)
                            .keyboardType(.emailAddress)
                            .focused($focusedField, equals: .email)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Password")
                            .customFont(.subheadline)
                            .foregroundColor(.secondary)
                        // Set isSecure to true so text is obscured.
                        AuthTextField(text: $password,
                                      placeholder: "Enter your password",
                                      icon: UIImage(named: "Icon Lock"),
                                      isSecure: true)
                            .frame(height: 50)
                            .focused($focusedField, equals: .password)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Confirm Password")
                            .customFont(.subheadline)
                            .foregroundColor(.secondary)
                        AuthTextField(text: $confirmPassword,
                                      placeholder: "Confirm your password",
                                      icon: UIImage(named: "Icon Lock"),
                                      isSecure: true)
                            .frame(height: 50)
                            .focused($focusedField, equals: .confirmPassword)
                    }
                    
                    if !signupError.isEmpty {
                        Text(signupError)
                            .foregroundColor(.red)
                            .customFont(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
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
                    .fullScreenCover(isPresented: $navigateToSignin) {
                        SignInView(showModal: .constant(true))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(30)
            .background(.regularMaterial)
            .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
            .shadow(color: Color("Shadow").opacity(0.3), radius: 30, x: 0, y: 30)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        .linearGradient(colors: [.white.opacity(0.8), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing)
                    )
            )
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
            
            VStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        showModal = false
                    }
                }) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    SignupView(showModal: .constant(true))
}
