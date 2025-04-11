//
//  OnboardingView.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-19.
//

import SwiftUI
import RiveRuntime

struct OnboardingView: View {
    var body: some View {
        RiveViewModel(fileName: "shapes").view()
            .ignoresSafeArea()
            .blur(radius: 30)
            .blendMode(.hardLight)
    }
}

#Preview {
    OnboardingView()
}
