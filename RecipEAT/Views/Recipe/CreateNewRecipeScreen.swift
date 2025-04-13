//
//  CreateNewRecipeScreen.swift
//  RecipEAT
//

import SwiftUI

struct CreateNewRecipeScreen: View {
    @Binding var selectedTab: Int

    @EnvironmentObject var recipeService: RecipeService
    @Environment(\.presentationMode) var presentationMode

    @State private var recipeTitle = ""
    @State private var recipeDescription = ""
    @State private var selectedCategory = "Breakfast"
    @State private var servings: Int = 1
    @State private var recipeImage: UIImage?
    @State private var showImagePicker = false
    @State private var ingredients: [Ingredients] = [Ingredients(name: "", quantity: "1", unit: "g")]
    @State private var instructions: [String] = [""]
    @State private var isPublished: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isPublishing = false

    private let categories = ["Breakfast", "Brunch", "Lunch", "Snack", "Dinner", "Dessert"]
    private let units = ["g", "kg", "ml", "L", "tsp", "tbsp", "cup", "pcs", "oz", "lb"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Image
                imageSection

                fieldSection(title: "Title", text: $recipeTitle)
                fieldSection(title: "Description", text: $recipeDescription)

                categorySection
                servingSection
                Toggle("Visible to Everyone", isOn: $isPublished)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    .customFont(.headline)

                ingredientsSection
                instructionsSection

                Button(action: {
                    publishRecipe()
                }) {
                    Text("Create recipe")
                        .customFont(.body)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(12)
                }
                .disabled(isPublishing)
            }
            .padding()
        }
        .navigationTitle("Create Recipe")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $recipeImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                if alertMessage.contains("successfully") {
                    resetForm()
                    withAnimation { selectedTab = 3 }
                }
            }))
        }
    }

    // MARK: - Sub Views
    
    private var imageSection: some View {
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
    }

    private func fieldSection(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).customFont(.body)
            TextField("Enter \(title.lowercased())...", text: text)
                .customTextField()
                .customFont(.headline)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category").customFont(.body)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        Button { selectedCategory = cat } label: {
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
    }

    private var servingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Serving").customFont(.body)
            HStack {
                Button { if servings > 1 { servings -= 1 } } label: {
                    Image(systemName: "minus.circle.fill").foregroundColor(Color(hex: "#e28e91")).font(.title2)
                }
                Text("\(servings)").font(.title3).padding(.horizontal, 8)
                Button { servings += 1 } label: {
                    Image(systemName: "plus.circle.fill").foregroundColor(Color(hex: "#e28e91")).font(.title2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }


    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients").customFont(.body)
            ForEach(ingredients.indices, id: \.self) { idx in
                HStack {
                    TextField("Qty", text: $ingredients[idx].quantity).customTextField().frame(width: 60).keyboardType(.numberPad)
                    TextField("Ingredient", text: $ingredients[idx].name).customTextField()
                    Picker("", selection: $ingredients[idx].unit) {
                        ForEach(units, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    Button { ingredients.remove(at: idx) } label: {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                }
            }
            Button("+ Add Ingredient") {
                ingredients.append(Ingredients(name: "", quantity: "1", unit: units.first ?? "g"))
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#e28e91"), lineWidth: 1))
        }
    }

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instructions").customFont(.body)
            ForEach(instructions.indices, id: \.self) { idx in
                HStack {
                    TextField("Step \(idx+1)", text: $instructions[idx]).customTextField()
                    Button { instructions.remove(at: idx) } label: {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                }
            }
            Button("+ Add Instruction") {
                instructions.append("")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#e28e91"), lineWidth: 1))
        }
    }

    private func publishRecipe() {
        guard !isPublishing else { return }
        guard !recipeTitle.trimmingCharacters(in: .whitespaces).isEmpty,
              !recipeDescription.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please fill in both title and description."
            showAlert = true
            return
        }

        isPublishing = true
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
            alertMessage = success ? "Recipe published successfully!" : (errorMsg ?? "Failed to publish recipe.")
            showAlert = true
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
        isPublishing = false
    }
}

#Preview {
    CreateNewRecipeScreen(selectedTab: .constant(3))
}
