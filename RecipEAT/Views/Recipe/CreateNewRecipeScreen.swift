//
//  CreateNewRecipeScreen.swift
//  RecipEAT
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
        Ingredients(name: "", quantity: "1", unit: "g")
    ]
    @State private var instructions: [String] = [""]

    @State private var isPublished: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    @EnvironmentObject var recipeService: RecipeService
    @Environment(\.presentationMode) var presentationMode

    private let categories = ["Breakfast", "Brunch", "Lunch", "Snack", "Dinner", "Dessert"]
    private let units = ["g", "kg", "ml", "L", "tsp", "tbsp", "cup", "pcs", "oz", "lb"]

    @State private var isPublishing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Image Picker
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#e28e91").opacity(0.1))
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
                                .foregroundColor(Color(hex: "#e28e91"))
                            Text("Tap to upload image")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onTapGesture { showImagePicker = true }

                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .customFont(.body)
                        .foregroundColor(.primary)
                    TextField("Recipe title", text: $recipeTitle)
                        .customTextField()
                        .customFont(.headline)
                }

                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .customFont(.body)
                        .foregroundColor(.primary)
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

                // Category
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .customFont(.body)
                        .foregroundColor(.primary)

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
                                        .background(selectedCategory == cat ? Color(hex: "#e28e91") : Color.gray.opacity(0.2))
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }

                // Serving
                VStack(alignment: .leading, spacing: 8) {
                    Text("Serving")
                        .customFont(.body)
                        .foregroundColor(.primary)
                    HStack {
                        Button(action: { if servings > 1 { servings -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(Color(hex: "#e28e91"))
                                .font(.title2)
                        }
                        Text("\(servings)")
                            .font(.title3)
                            .padding(.horizontal, 8)
                        Button(action: { servings += 1 }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(hex: "#e28e91"))
                                .customFont(.title2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Toggle("Visible to Everyone", isOn: $isPublished)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    .customFont(.headline)

                // Ingredients
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .customFont(.body)
                        .foregroundColor(.primary)

                    ForEach(ingredients.indices, id: \.self) { idx in
                        HStack {
                            TextField("Qty", text: $ingredients[idx].quantity)
                                .customTextField()
                                .frame(width: 60)
                                .keyboardType(.numberPad)

                            TextField("Ingredient", text: $ingredients[idx].name)
                                .customTextField()

                            Picker("Unit", selection: $ingredients[idx].unit) {
                                ForEach(units, id: \.self) {
                                    Text($0).tag($0)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 5)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(16)

                            Button(action: {
                                ingredients.remove(at: idx)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Button(action: {
                        ingredients.append(Ingredients(name: "", quantity: "1", unit: units.first ?? "g"))
                    }) {
                        Text("+ Add Ingredient")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "#e28e91"), lineWidth: 1)
                            )
                    }
                    .padding(.top, 4)
                }

                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions")
                        .customFont(.body)
                        .foregroundColor(.primary)

                    ForEach(instructions.indices, id: \.self) { idx in
                        HStack {
                            TextField("Instruction \(idx+1)", text: $instructions[idx])
                                .customTextField()

                            Button(action: {
                                instructions.remove(at: idx)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Button(action: {
                        instructions.append("")
                    }) {
                        Text("+ Add Instruction")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "#e28e91"), lineWidth: 1)
                            )
                    }
                    .padding(.top, 4)
                }

                // Final Button
                Button(action: {
                    guard !isPublishing else { return }
                    guard !recipeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                          !recipeDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        alertMessage = "Please enter a title and description at least before publishing your recipe."
                        showAlert = true
                        return
                    }
                    
                    isPublishing = true // ✅ lock submission

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
                        alertMessage = success ? "Recipe published successfully!" :
                            (errorMsg ?? "Failed to publish recipe.")
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
            Alert(
                title: Text("Message"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"), action: {
                    resetForm()
                    withAnimation {
                        selectedTab = 3
                    }
                })
            )
        }
    }

    private func resetForm() {
        recipeTitle = ""
        recipeDescription = ""
        selectedCategory = "Breakfast"
        servings = 1
        recipeImage = nil
        ingredients = [Ingredients(name: "", quantity: "1", unit: units.first ?? "g")]
        instructions = [""]
        isPublished = false
    }
}

#Preview {
    CreateNewRecipeScreen(selectedTab: .constant(2))
}
