import Foundation
import SwiftData

@Model
final class GroceryListItem {
    var id: UUID
    var ingredientName: String
    var quantity: String?
    var recipeID: String?
    var recipeName: String?
    var addedAt: Date
    var isChecked: Bool

    init(
        ingredientName: String,
        quantity: String? = nil,
        recipeID: String? = nil,
        recipeName: String? = nil,
        addedAt: Date = .now,
        isChecked: Bool = false
    ) {
        self.id = UUID()
        self.ingredientName = ingredientName
        self.quantity = quantity
        self.recipeID = recipeID
        self.recipeName = recipeName
        self.addedAt = addedAt
        self.isChecked = isChecked
    }
}
