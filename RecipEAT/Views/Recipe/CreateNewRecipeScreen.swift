//
//  CreateNewRecipeScreen.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import SwiftUI

struct CreateNewRecipeScreen: View {
    @Binding var selectedTab: Int
    
    @State private var recipeTitle = ""
    @State private var recipeDescription = ""
    @State private var selectedCategory = "Breakfast"
    @State private var servings: Int = 1
    @State private var recipeImage: UIImage?
    @State private var showImagePicker = false
    
    @State private var ingredients: [Ingredients] = [
        Ingredients(name: "", quantity: "1", unit: "")
    ]
    @State private var instructions: [String] = [""]
    
    @State private var isPublished: Bool = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @EnvironmentObject var recipeService: RecipeService
    @Environment(\.presentationMode) var presentationMode
    
    private let categories = ["Breakfast", "Brunch", "Lunch", "Snack", "Dinner", "Dessert"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Image selection
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.pink.opacity(0.1))
                        .frame(width: 380, height: 200)
                    VStack(spacing: 8) {
                        if let image = recipeImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 370, height: 190)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Image(systemName: "photo.on.rectangle.angled")
                                .customFont(.largeTitle)
                                .foregroundColor(.pink)
                            Text("Tap to upload image")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onTapGesture { showImagePicker = true }
                
                // Title Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .customFont(.body)
                        .foregroundColor(.secondary)
                    TextField("Recipe title", text: $recipeTitle)
                        .customTextField()
                        .customFont(.headline)
                }
                
                // Description Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .customFont(.body)
                        .foregroundColor(.secondary)
                    ZStack(alignment: .topLeading) {
                        if recipeDescription.isEmpty {
                            Text("Enter description...")
                                .foregroundColor(.secondary.opacity(0.6))
                                .customFont(.headline)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 18)
                        }
                        TextEditor(text: $recipeDescription)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                            .customTextField()
                            .onChange(of: recipeDescription) { oldValue, newValue in
                                if newValue.count > 60 {
                                    recipeDescription = String(newValue.prefix(60))
                                }
                            }
                    }
                    
                    HStack {
                        Spacer()
                        Text("\(recipeDescription.count)/60")
                            .customFont(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // MARK: Category Slider
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .customFont(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Button(action: {
                                    selectedCategory = cat
                                }) {
                                    Text(cat)
                                        .foregroundColor(selectedCategory == cat ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == cat ? Color.pink : Color.gray.opacity(0.2))
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
                
                // Serving stepper
                VStack(alignment: .leading, spacing: 8) {
                    Text("Serving")
                        .customFont(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Button(action: { if servings > 1 { servings -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.pink)
                                .font(.title2)
                        }
                        Text("\(servings)")
                            .font(.title3)
                            .padding(.horizontal, 8)
                        Button(action: { servings += 1 }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.pink)
                                .customFont(.title2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Publish toggle
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Visible to Everyone", isOn: $isPublished)
                        .toggleStyle(SwitchToggleStyle(tint: .pink))
                        .customFont(.headline)
                }
                
                // Ingredients Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .customFont(.body)
                        .foregroundColor(.secondary)
                    ForEach(ingredients.indices, id: \.self) { idx in
                        HStack {
                            TextField("Qty", text: $ingredients[idx].quantity)
                                .frame(width: 60)
                                .padding()
                                .background(Color.pink.opacity(0.1))
                                .cornerRadius(8)
                                .keyboardType(.numberPad)
                            
                            TextField("Ingredient", text: $ingredients[idx].name)
                                .padding()
                                .background(Color.pink.opacity(0.1))
                                .cornerRadius(8)
                            TextField("Unit", text: $ingredients[idx].unit)
                                .frame(width: 60)
                                .padding()
                                .background(Color.pink.opacity(0.1))
                                .cornerRadius(8)
                                .keyboardType(.numberPad)
                            
                            Button(action: { ingredients.remove(at: idx) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button(action: {
                        ingredients.append(Ingredients(name: "", quantity: "1", unit: ""))
                    }) {
                        Text("+ Add Ingredient")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(8)
                    }
                }
                
                // Instructions Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions")
                        .customFont(.body)
                        .foregroundColor(.secondary)
                    ForEach(instructions.indices, id: \.self) { idx in
                        HStack {
                            TextField("Instruction \(idx+1)", text: $instructions[idx])
                                .customTextField()
                            Button(action: { instructions.remove(at: idx) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button(action: { instructions.append("") }) {
                        Text("+ Add Instruction")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(8)
                    }
                }
                
                // Publish button
                Button(action: {
                    guard !recipeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                          !recipeDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        alertMessage = "Please enter a title and description at least before publishing your recipe."
                        showAlert = true
                        return
                    }
                    recipeService.publishRecipe(
                        title: recipeTitle,
                        description: recipeDescription,
                        ingredients: ingredients,
                        instructions: instructions,
                        servings: servings,
                        category: selectedCategory,
                        image: recipeImage,
                        isPublished: isPublished
                    ) { success, errorMsg in
                        if success {
                            alertMessage = "Recipe published successfully!"
                        } else {
                            alertMessage = errorMsg ?? "Failed to publish recipe."
                        }
                        showAlert = true
                    }
                }) {
                    Text("Create recipe")
                        .customFont(.body)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Create Recipe")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $recipeImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Message"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK"), action: {
                // Reset the form fields
                resetForm()
                withAnimation {
                    selectedTab = 3
                }
            }))
        }
    }
    
    // Helper function to reset all form fields
    private func resetForm() {
        recipeTitle = ""
        recipeDescription = ""
        selectedCategory = "Breakfast"
        servings = 1
        recipeImage = nil
        ingredients = [Ingredients(name: "", quantity: "1", unit: "")]
        instructions = [""]
        isPublished = false
    }
}

#Preview {
    CreateNewRecipeScreen(selectedTab: .constant(2))
}
