//
//  ChangeNameScreen.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-03-20.
//

import SwiftUI

struct ChangeNameScreen: View {
    @EnvironmentObject var userService: UserFirebaseService
    @State private var newName: String = ""
    @State private var saveError: String = ""
    @State private var isSaving = false
    @State private var successMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Change Display Name")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 5) {
                    TextField("Enter new display name", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .frame(height: 50)
                }
                .padding(.horizontal)
                
                if !saveError.isEmpty {
                    Text(saveError)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    // clear error msg before processing
                    saveError = ""

                    guard !newName.isEmpty else {
                        saveError = "Display name cannot be empty."
                        return
                    }
                    isSaving = true
                    userService.updateProfile(displayName: newName, newPassword: nil) { error in
                        isSaving = false
                        if let error = error {
                            saveError = error.localizedDescription
                        } else {
                            saveError = ""
                            successMessage = "Display name updated successfully!"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }) {
                    Text("Update")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Change Name", displayMode: .inline)
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

struct ChangeNameScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChangeNameScreen().environmentObject(UserFirebaseService())
    }
}
