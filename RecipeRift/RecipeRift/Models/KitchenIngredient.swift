//
//  KitchenIngredient.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-17.
//

import SwiftData
import Foundation

@Model
class KitchenIngredient {
    var id: UUID
    var name: String
    var category: String
    var howMuch: String?
    var expiresOn: Date?
    var whenAdded: Date
    var isSelected: Bool
    
    @Relationship(deleteRule: .nullify, inverse: \SavedRecipe.ingredientsUsed)
    var recipesUsingThis: [SavedRecipe]?
    
    init(name: String, category: String, howMuch: String? = nil, expiresOn: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.howMuch = howMuch
        self.expiresOn = expiresOn
        self.whenAdded = Date()
        self.isSelected = false
        self.recipesUsingThis = []
    }
    
    var isExpiringSoon: Bool {
        guard let expiryDate = expiresOn else { return false }
        let threeDaysFromNow = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        return expiryDate <= threeDaysFromNow
    }
}
