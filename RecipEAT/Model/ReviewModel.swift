//
//  ReviewModel.swift
//  RecipEAT
//
//  Created by hazelclarisse on 2025-02-19.
//

import Foundation
import FirebaseFirestore

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var reviewId: String
    var userId: String
    var rating: String
    var comment: String
    var createdAt: Date
}
