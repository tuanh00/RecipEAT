//
//  AddMealScreen.swift
//  RecipEAT
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
    @State private var recipeName: String = ""
    @State private var notes: String = ""
    @State private var category: String = "Breakfast"
    @State private var query: String = ""
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
                        TextField("Enter recipe name/description...", text: $query)
                            .padding(.vertical, 8)
                            .onChange(of: query) { oldValue, newValue in
                                handleQueryChange(newValue)
                            }
                            .autocapitalization(.none)
                            .focused($isQueryFieldFocused)

                        if isQueryFieldFocused && !suggestedRecipes.isEmpty {
                            List(suggestedRecipes) { r in
                                Text(r.title)
                                    .padding(.vertical, 4)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        query = r.title
                                        recipeName = r.title
                                        suggestedRecipes = []
                                        isQueryFieldFocused = false
                                    }
                                    .listRowInsets(EdgeInsets())
                            }
                            .listStyle(.plain)
                            .frame(height: 120)
                            .offset(y: 40)
                        }
                    }
                    .clipped()
                }

                Section(header: Text("Notes")) {
                    TextField("Any notes...", text: $notes)
                }
            }
            .navigationTitle("Add Meal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveMeal() }
                }
            }
        }
    }

    private func saveMeal() {
        // Always save whatever user types
        let finalName = query.isEmpty ? recipeName : query

        let meal = Meal(
            recipeName: finalName,
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

    private func handleQueryChange(_ newValue: String) {
        if newValue.isEmpty {
            suggestedRecipes = []
        } else {
            recipeService.searchRecipes(prefix: newValue) { results, error in
                if let error = error {
                    print("Search Error: \(error.localizedDescription)")
                    suggestedRecipes = []
                } else {
                    suggestedRecipes = results
                }
            }
        }
    }
}

