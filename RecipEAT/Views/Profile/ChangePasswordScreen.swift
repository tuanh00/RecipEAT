    //
    //  ChangePasswordScreen.swift
    //  RecipEAT
    //
    //  Created by user269332 on 3/17/25.
    //

import SwiftUI

struct ChangePasswordScreen: View {
    @EnvironmentObject var userService: UserFirebaseService
    @State private var newPassword: String = ""
    @State private var newDisplayName: String = ""
    @State private var confirmPassword: String = ""
    @State private var saveError: String = ""
    @State private var isSaving = false
    @State private var successMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Change Password")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)
            
            SecureField("Enter New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Confirm New Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding(.horizontal)
            }
 
            if successMessage == nil && !saveError.isEmpty {
                Text(saveError)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Button("Update") {
                guard !newPassword.isEmpty else {
                    saveError = "New password cannot be empty."
                    return
                }
                
                guard newPassword == confirmPassword else {
                    saveError = "Passwords do not match."
                    return
                }
                
                isSaving = true
                userService
                    .updateProfile(
                        displayName: userService.currentUser?.displayName,
                        newPassword: newPassword
                    ) { error in
                    isSaving = false
                    if let error = error {
                        saveError = error.localizedDescription
                    } else {
                        successMessage = "Password updated successfully!"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            
            Spacer()
            
                // Close button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .opacity(0.7)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .navigationBarTitle("Change Password", displayMode: .inline)
    }
}

#Preview {
    ChangePasswordScreen()
        .environmentObject(UserFirebaseService())
}
