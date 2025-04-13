//
//  CustomTextField.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-23.
//

import SwiftUI

struct CustomTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
    }
}

extension View {
    func customTextField() -> some View {
        modifier(CustomTextField())
    }
}


