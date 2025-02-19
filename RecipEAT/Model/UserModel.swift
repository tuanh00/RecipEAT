//
//  UserModel.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String?
    var userId: String?
    var email: String
    var displayName: String
    var imageUrl: String
}
