import Foundation
import SwiftData

@Model
final class RecentRecipe {
    var id: UUID
    var recipeID: String
    var recipeName: String
    var pictureURL: String?
    var cuisineType: String?
    var viewedAt: Date

    init(
        recipeID: String,
        recipeName: String,
        pictureURL: String? = nil,
        cuisineType: String? = nil,
        viewedAt: Date = .now
    ) {
        self.id = UUID()
        self.recipeID = recipeID
        self.recipeName = recipeName
        self.pictureURL = pictureURL
        self.cuisineType = cuisineType
        self.viewedAt = viewedAt
    }
}
