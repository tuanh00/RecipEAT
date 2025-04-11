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
    @State private var confirmPassword: String = ""
    @State private var saveError: String = ""
    @State private var isSaving = false
    @State private var successMessage: String?
    @FocusState private var isPasswordFieldFocused: Bool //focus state for password
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Change Password")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("New Password")
                        .font(.headline)
                    SecureField("Enter new password", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true) //turn-off auto-suggestion
                        .autocapitalization(.none)
                        .frame(height: 50)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Confirm Password")
                        .font(.headline)
                    SecureField("Re-enter new password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .frame(height: 50)
                        .focused($isPasswordFieldFocused)
                }
                .padding(.horizontal)
                
                // Show error message if any
                if !saveError.isEmpty {
                    Text(saveError)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // Show success message if any
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }
                
                Button("Update") {
                    //clear error msg before processing
                    saveError = ""
                    
                    guard !newPassword.isEmpty else {
                        saveError = "New password cannot be empty."
                        return
                    }
                    
                    guard newPassword.count >= 6 else {
                        saveError = "Password must be at least 6 characters."
                        return
                    }
                    
                    guard newPassword == confirmPassword else {
                        saveError = "Passwords do not match."
                        confirmPassword = "" //clear field
                        isPasswordFieldFocused = true //refocus on confirm password field
                        return
                    }
                    
                    isSaving = true
                    userService.updateProfile(
                        displayName: userService.currentUser?.displayName,
                        newPassword: newPassword
                    ) { error in
                        isSaving = false
                        if let error = error {
                            saveError = error.localizedDescription
                        } else {
                            saveError = ""
                            successMessage = "Password updated successfully!"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Change Password", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
    }
}

struct ChangePasswordScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordScreen().environmentObject(UserFirebaseService())
    }
}
