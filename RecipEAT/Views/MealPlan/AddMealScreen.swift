//
//  AddMealScreen.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-24.
//

import SwiftUI

struct AddMealScreen: View {
    let planId: String
    let defaultDate: Date
    let onSave: () -> Void
    
    @EnvironmentObject var mealPlanService: MealPlanService
    @EnvironmentObject var recipeService: RecipeService
    @Environment(\.dismiss) var dismiss
    
    @State private var date: Date
    @State private var recipeName: String = "" //Set if user taps a suggestions
    @State private var notes: String = ""
    @State private var category: String = "Breakfast" //default
    @State private var query: String = "" // Text entered in the field
    @State private var suggestedRecipes: [Recipe] = []
    
    @FocusState private var isQueryFieldFocused: Bool
    
    private let categories = ["Breakfast", "Brunch", "Lunch", "Dinner", "Dessert"]
    
    init(planId: String, defaultDate: Date, onSave: @escaping () -> Void) {
        self.planId = planId
        self.defaultDate = defaultDate
        self.onSave = onSave
        _date = State(initialValue: defaultDate)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Date")) {
                    DatePicker("Meal Date", selection: $date, displayedComponents: .date)
                }
                Section(header: Text("Meal Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section("Recipe") {
                    ZStack(alignment: .topLeading) {
                        // The text field
                        TextField("Enter recipe name/description...", text: $query)
                            .padding(.vertical, 8)
                            .onChange(of: query) { oldValue, newValue in
                                handleQueryChange(newValue)
                            }
                            .autocapitalization(.none)
                            .focused($isQueryFieldFocused)
                        
                        if isQueryFieldFocused && !suggestedRecipes.isEmpty {
                            // The suggestions list, overlayed
                            List(suggestedRecipes) { r in
                                Text(r.title)
                                    .padding(.vertical, 4)
                                    .contentShape(Rectangle())  // so the tap area is the full row width
                                    .onTapGesture {
                                        // user selected this suggestion
                                        query = r.title
                                        recipeName = r.title
                                        suggestedRecipes = []
                                        
                                        isQueryFieldFocused = false
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            }
                            .listStyle(.plain)
                            .frame(height: 120)
                            // Offset it below the text field
                            .offset(y: 40)
                        }
                    }
                    .clipped() // Ensures the overlay doesn’t bleed beyond Section boundaries
                }
                Section(header: Text("Notes")) {
                    TextField("Any notes...", text: $notes)
                }
            }
            .navigationTitle("Add Meal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMeal()
                    }
                }
            }
        }
    }
    
    func saveMeal() {
        //let finalName = recipeName.isEmpty ? query : recipeName

        let meal = Meal(
            recipeName: recipeName,
            date: date,
            notes: notes,
            category: category
        )
        mealPlanService.addMeal(to: planId, meal: meal) { success, error in
            if success {
                onSave()
                dismiss()
            } else {
                print("Error saving meal: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    // Searching Recipes
    func handleQueryChange(_ newValue: String) {
        // If user just tapped a suggestion, do not re-search
              if newValue == recipeName {
                  return
              }
        
        // Otherwise, search
        if !newValue.isEmpty {
            recipeService.searchRecipes(prefix: newValue) { results, error in
                if let error = error {
                    // handle or log the error
                    print("Error searching recipes: \(error.localizedDescription)")
                    suggestedRecipes = []
                } else {
                    // results is always [Recipe], so no need for if let
                    suggestedRecipes = results
                }
            }
        } else {
            suggestedRecipes = []
        }
    }
}

#Preview {
    AddMealScreen(planId: "testPlan", defaultDate: Date()) {
        print("Meal saved.")
    }
    .environmentObject(MealPlanService())
    .environmentObject(RecipeService())
}
