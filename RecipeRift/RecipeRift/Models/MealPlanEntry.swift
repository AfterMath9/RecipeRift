import Foundation
import SwiftData

@Model
final class MealPlanEntry {
    var id: UUID
    var recipeID: String
    var recipeName: String
    var recipeImageURL: String?
    var date: Date
    var mealSlot: String
    var createdAt: Date

    init(
        recipeID: String,
        recipeName: String,
        recipeImageURL: String? = nil,
        date: Date,
        mealSlot: String = "Dinner"
    ) {
        self.id = UUID()
        self.recipeID = recipeID
        self.recipeName = recipeName
        self.recipeImageURL = recipeImageURL
        self.date = date
        self.mealSlot = mealSlot
        self.createdAt = .now
    }
}
