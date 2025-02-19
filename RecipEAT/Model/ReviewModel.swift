//
//  ReviewModel.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import Foundation

struct Review: Identifiable, Codable {
    var id: String?
    var reviewId: String
    var userId: String
    var rating: String
    var comment: String
    var createdAt: Date
}
