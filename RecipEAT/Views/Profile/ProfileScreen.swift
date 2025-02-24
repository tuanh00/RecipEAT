//
//  ProfileScreen.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileScreen: View {
    @EnvironmentObject var userService: UserFirebaseService
    @State private var newDisplayName: String = ""
    @State private var newPassword: String = ""
    @State private var isSaving = false
    @State private var saveError: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 10) {
            if let user = userService.currentUser {
                // Display user avatar from URL. If URL is invalid, fall back to the asset.
                AsyncImage(url: URL(string: user.imageUrl)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Image("defaultAvatar")
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.8), lineWidth: 1))
                .padding(.top, 40)
                
                // Change Avatar label (to implement later)
                Button("Change Avatar") {
                    // Future implementation for updating avatar
                }
                .padding(.top, 8)
                
                Text("Display Name")
                    .customFont(.title3)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Editable display name text field
                TextField("Display Name", text: $newDisplayName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onAppear {
                        newDisplayName = user.displayName
                    }
                
                if let created = user.createdAt as Date? {
                    Text("Member since: \(created.formatted(date: .abbreviated, time: .omitted))")
                        .customFont(.title3)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Show new password field only if user.password is non‑empty.
                if !user.password.isEmpty {
                    Text("Set new password")
                        .customFont(.title3)
                        .padding(.horizontal)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    SecureField("Enter new Password", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                
                // Save button
                Button("Save") {
                    updateProfile()
                }
                .padding()
                .foregroundColor(.white)
                .cornerRadius(10)
                
                if !saveError.isEmpty {
                    Text(saveError)
                        .foregroundColor(.red)
                }
                
                Spacer()
            } else {
                Text("No user data available.")
            }
        }
        .navigationBarTitle("Profile", displayMode: .inline)
    }
    
    func updateProfile() {
        guard let user = userService.currentUser else { return }
        isSaving = true
        var updates: [String: Any] = [:]
        
        if newDisplayName != user.displayName {
            updates["displayName"] = newDisplayName
        }
        if !newPassword.isEmpty {
            let hashedPassword = Data(newPassword.utf8).base64EncodedString()
            updates["password"] = hashedPassword
            // Update FirebaseAuth password as well
            Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                if let error = error {
                    print("Error updating Auth password: \(error.localizedDescription)")
                }
            }
        }
        
        if updates.isEmpty {
            isSaving = false
            presentationMode.wrappedValue.dismiss()
            return
        }
        
        let userDoc = Firestore.firestore().collection("users").document(user.id ?? "")
        userDoc.updateData(updates) { error in
            isSaving = false
            if let error = error {
                saveError = error.localizedDescription
            } else {
                // Update local copy
                userService.currentUser?.displayName = newDisplayName
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    ProfileScreen()
        .environmentObject(UserFirebaseService())
}
