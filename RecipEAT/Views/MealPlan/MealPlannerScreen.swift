//
//  MealPlannerScreen.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import SwiftUI

struct MealPlannerScreen: View {
    @Binding var selectedTab: Int

    var body: some View {
        Text("Meal Planner Screen")
    }
}

#Preview {
    MealPlannerScreen(selectedTab: .constant(3))
}
