//
//  AuthTextField.swift
//  RecipEAT
//
//  Created by LaSalle on 2025-02-19.
//

import SwiftUI

struct AuthTextField: ViewModifier {
    var image: Image
    
    func body(content: Content) -> some View {
        content
            .padding(15)
            .padding(.leading, 36)
            .background(.white)
            .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke()
                .fill(.black.opacity(0.1))
            )
            .overlay(
                image
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
            )
    }
}

extension View {
    func customAuthTextField(image: Image = Image("Icon Email")) -> some View {
        modifier(AuthTextField(image: image))
    }
}
