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
            .background(Color.pink.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke()
                    .fill(.pink.opacity(0.5))
                    .cornerRadius(30)
            )
    }
}

extension View {
    func customTextField() -> some View {
        modifier(CustomTextField())
    }
}


