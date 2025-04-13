//
//  UpdateRecipeScreen.swift
//  RecipEAT
//

import SwiftUI

struct UpdateRecipeScreen: View {
    @EnvironmentObject var recipeService: RecipeService
    @EnvironmentObject var mealPlanService: MealPlanService
    // Use the newer dismiss instead of presentationMode
    @Environment(\.dismiss) var dismiss
    
    let recipe: Recipe
    
    @State private var title: String
    @State private var description: String
    @State private var ingredients: [Ingredients]
    @State private var instructions: [String]
    @State private var isPublished: Bool
    @State private var servings: Int
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteAlert = false
    @State private var isUpdating = false
    @State private var newImage: UIImage? = nil
    @State private var showImagePicker = false
    
    private let units = ["g", "kg", "ml", "L", "tsp", "tbsp", "cup", "pcs", "oz", "lb"]

    init(recipe: Recipe) {
        self.recipe = recipe
        _title = State(initialValue: recipe.title)
        _description = State(initialValue: recipe.description)
        _ingredients = State(initialValue: recipe.ingredients)
        _instructions = State(initialValue: recipe.instructions)
        _isPublished = State(initialValue: recipe.isPublished)
        _servings = State(initialValue: recipe.servings)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                imageSection
                textFieldsSection
                servingsSection         // Already left-aligned per previous update
                ingredientsSection
                instructionsSection
                
                Toggle("Visible to Everyone", isOn: $isPublished)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                
                updateButton
                deleteButton   
            }
            .padding()
        }
        .navigationTitle("Update Recipe")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $newImage)
        }
        // Alert after update or error
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {
                // No notification posted here so that update returns to RecipeDetails
                // CHANGED: Removed notification post so that update success returns to RecipeDetails.
                if alertMessage.contains("updated successfully") {
                    dismiss()
                }
            }
        }
        // Confirmation alert for deletion
        .alert("Are you sure you want to delete this recipe?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                checkAndDeleteRecipe()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: Image Section with edit icon
    private var imageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let newImage = newImage {
                    Image(uiImage: newImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    AsyncImage(url: URL(string: recipe.imageUrl)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Button {
                showImagePicker = true
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.title)
                    .padding(8)
            }
        }
    }
    
    // MARK: Title & Description
    private var textFieldsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title").font(.headline)
            TextField("Title", text: $title).customTextField()
            
            Text("Description").font(.headline)
            TextField("Description", text: $description).customTextField()
        }
    }
    
    // MARK: Servings Section (Forced left alignment)
    private var servingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Servings").font(.headline)
            HStack {
                Button(action: {
                    if servings > 1 { servings -= 1 }
                }) {
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
                        .font(.title2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: Ingredients Section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients").font(.headline)
            
            ForEach(ingredients.indices, id: \.self) { idx in
                HStack {
                    TextField("Qty", text: $ingredients[idx].quantity)
                        .customTextField()
                        .frame(width: 60)
                    TextField("Ingredient", text: $ingredients[idx].name)
                        .customTextField()
                    Picker("Unit", selection: $ingredients[idx].unit) {
                        ForEach(units, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 16)
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
    
    // MARK: Instructions Section
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instructions").font(.headline)
            
            ForEach(instructions.indices, id: \.self) { idx in
                HStack {
                    TextField("Step \(idx + 1)", text: $instructions[idx])
                        .customTextField()
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
    
    // MARK: Update Button
    private var updateButton: some View {
        Button("Update Recipe") {
            guard !isUpdating else { return }
            isUpdating = true
            if let newImage = newImage {
                recipeService.uploadRecipeImage(image: newImage) { result in
                    switch result {
                    case .success(let imageUrl):
                        updateRecipe(newImageUrl: imageUrl)
                    case .failure(let error):
                        alertMessage = "Image upload failed: \(error.localizedDescription)"
                        showAlert = true
                        isUpdating = false
                    }
                }
            } else {
                updateRecipe()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(Color.accentColor)
        .cornerRadius(12)
    }
    
    // MARK: Delete Button (Remains unchanged)
    private var deleteButton: some View {
        Button("Delete Recipe") {
            showDeleteAlert = true
        }
        .padding()
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(Color.red)
        .cornerRadius(12)
    }
    
    // MARK: Update Recipe Function
    private func updateRecipe(newImageUrl: String? = nil) {
        recipeService.updateRecipe(
            recipeId: recipe.id ?? "",
            title: title,
            description: description,
            ingredients: ingredients,
            instructions: instructions,
            servings: servings,
            isPublished: isPublished,
            newImageUrl: newImageUrl
        ) { success, errorMsg in
            if success {
                // CHANGED: On update success, simply dismiss the UpdateRecipeScreen
                dismiss()
            } else {
                alertMessage = errorMsg ?? "Failed to update."
                showAlert = true
            }
            isUpdating = false
        }
    }
    
    // MARK: Delete Recipe Function
    private func checkAndDeleteRecipe() {
        recipeService.deleteRecipe(recipeId: recipe.id ?? "", userId: recipe.userId) { success, errorMsg in
            if success {
                // On deletion, post notification so that ContentView switches to Personal Recipe Screen (My Recipes tab)
                NotificationCenter.default.post(name: Notification.Name("GoToMyRecipesTab"), object: nil)
                dismiss()
            } else {
                alertMessage = errorMsg ?? "Failed to delete."
                showAlert = true
            }
        }
    }
}
