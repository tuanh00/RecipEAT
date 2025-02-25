//
//  MealPlannerScreen.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import SwiftUI
import FirebaseAuth

struct MealPlannerScreen: View {
    @Binding var selectedTab: Int
    
    @EnvironmentObject var mealPlanService: MealPlanService
    
    @State private var userId: String = Auth.auth().currentUser?.uid ?? "unknown"
    @State private var currentWeekStart: Date = Date()
    @State private var mealPlan: MealPlan?
    @State private var errorMessage = ""
    
    @State private var showAddMeal = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button("Previous") {
                        withAnimation {
                            currentWeekStart = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStart)!
                            loadMealPlan()
                        }
                    }
                    Spacer()
                    Text(weekLabel)
                        .customFont(.headline)
                    Spacer()
                    Button("Next") {
                        withAnimation {
                            currentWeekStart = Calendar.current.date(byAdding: .day, value: 7, to: currentWeekStart)!
                            loadMealPlan()
                        }
                    }
                }
                .padding()
                
                if let plan = mealPlan {
                    List {
                        ForEach(0..<7, id: \.self) { offset in
                            let day = Calendar.current.date(byAdding: .day, value: offset, to: plan.startDate)!
                            Section(header: Text(formattedDate(day))) {
                                let dayMeals = plan.meals.filter { isSameDay($0.date, day) }
                                                          .sorted { $0.date < $1.date }
                                if dayMeals.isEmpty {
                                    Button("+ Add meal") {
                                        selectedDate = day
                                        showAddMeal = true
                                    }
                                } else {
                                    ForEach(dayMeals, id: \.id) { meal in
                                        HStack {
                                            Image(iconName(for: meal.category))
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .padding(.trailing, 8)
                                            
                                            Text(meal.recipeName)
                                                .customFont(.headline)
                                            
                                            Spacer()
                                            
                                            Text(meal.notes)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Button("+ Add meal") {
                                        selectedDate = day
                                        showAddMeal = true
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        Text("Loading Meal Plan...")
                    }
                }
            }
            .navigationTitle("Meal Planner")
            .onAppear {
                loadMealPlan()
            }
            .sheet(isPresented: $showAddMeal, onDismiss: {
                loadMealPlan()  // Refresh the plan after dismissing AddMealScreen
            }) {
                AddMealScreen(planId: mealPlan?.id ?? "", defaultDate: selectedDate, onSave: {
                    loadMealPlan()
                })
            }
            .presentationDetents([.medium])
        }
    }
    
    func loadMealPlan() {
        let start = startOfWeek(currentWeekStart)
        mealPlanService.fetchMealPlan(for: userId, weekStart: start) { plan, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    mealPlan = plan
                }
            }
        }
    }
    
    var weekLabel: String {
        guard let plan = mealPlan else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return "\(formatter.string(from: plan.startDate)) - \(formatter.string(from: plan.endDate))"
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        if Calendar.current.isDateInToday(date) {
            return "Today - " + formatter.string(from: date)
        }
        return formatter.string(from: date)
    }
    
    func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        Calendar.current.isDate(d1, inSameDayAs: d2)
    }
    
    func startOfWeek(_ date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    func iconName(for category: String) -> String {
        switch category {
        case "Breakfast": return "Breakfast Icon"
        case "Brunch": return "Brunch Icon"
        case "Lunch": return "Lunch Icon"
        case "Dinner": return "Dinner Icon"
        case "Dessert": return "Dessert Icon"
        default: return "Breakfast Icon"
        }
    }
}

#Preview {
    MealPlannerScreen(selectedTab: .constant(3))
        .environmentObject(MealPlanService())
        .environmentObject(RecipeService())
}
