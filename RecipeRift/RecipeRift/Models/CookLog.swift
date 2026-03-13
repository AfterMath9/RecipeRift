import Foundation
import SwiftData

@Model
final class CookLog {
    var id: UUID
    var cookedAt: Date
    var rating: Int?
    var notes: String?
    var photoData: Data?
    var personalDifficulty: String?
    var personalPrepMinutes: Int?
    var personalServings: Int?
    var recipe: SavedRecipe?

    init(
        cookedAt: Date = .now,
        rating: Int? = nil,
        notes: String? = nil,
        photoData: Data? = nil,
        personalDifficulty: String? = nil,
        personalPrepMinutes: Int? = nil,
        personalServings: Int? = nil,
        recipe: SavedRecipe? = nil
    ) {
        self.id = UUID()
        self.cookedAt = cookedAt
        self.rating = rating
        self.notes = notes
        self.photoData = photoData
        self.personalDifficulty = personalDifficulty
        self.personalPrepMinutes = personalPrepMinutes
        self.personalServings = personalServings
        self.recipe = recipe
    }
}
