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
                
                // Save button calls the service's updateProfile.
                Button("Save") {
                    isSaving = true
                    userService.updateProfile(displayName: newDisplayName, newPassword: newPassword) { error in
                        isSaving = false
                        if let error = error {
                            saveError = error.localizedDescription
                        } else {
                            // Optionally dismiss or give feedback.
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                
                if !saveError.isEmpty {
                    Text(saveError)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Log Out
                Button(action: {
                    Task {
                        do {
                            try await userService.logout()
                        } catch {
                            print("Error during logout: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            } else {
                Text("No user data available.")
            }
        }
        .navigationBarTitle("Profile", displayMode: .inline)
    }
}

#Preview {
    ProfileScreen()
        .environmentObject(UserFirebaseService())
}
