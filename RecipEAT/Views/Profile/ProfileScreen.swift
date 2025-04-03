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
    @State private var isChangePasswordPresented = false
    @State private var isChangeNamePresented = false
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage? = nil
    
    
    var body: some View {
        VStack(spacing: 20) {
            if let user = userService.currentUser {
                //Avatar + pencil overlay
                ZStack(alignment: .bottomTrailing){
                    // User avatar display
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
                    
                    //Pencil icon button
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .padding(8)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                .sheet(isPresented: $isImagePickerPresented, onDismiss: {
                    if let image = selectedImage {
                        userService.updateAvatar(image: image) {
                            success, error in
                        }
                    }
                }) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                
                //Display name
                Button(action: {
                    isChangeNamePresented = true
                }) {
                    HStack {
                        Text("Name")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(user.displayName)
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                }
                .padding(.horizontal)
                .sheet(isPresented: $isChangeNamePresented) {
                    ChangeNameScreen()
                        .environmentObject(userService)
                }
                
                // MARK: Conditionally show Change Password row for non-Gmail users.
                if !user.password.isEmpty {
                    //Change pwd row
                    Button(action: {
                        isChangePasswordPresented = true
                    }) {
                        HStack {
                            Text("Change password")
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $isChangePasswordPresented) {
                        ChangePasswordScreen()
                            .environmentObject(userService)
                    }
                }
                
                if let created = user.createdAt as Date? {
                    Text("Member since: \(created.formatted(date: .abbreviated, time: .omitted))")
                        .customFont(.title3)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            } else {
                Text("No user data available.")
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileScreen()
        .environmentObject(UserFirebaseService())
}
