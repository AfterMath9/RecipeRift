import Foundation
import SwiftData

@Model
final class RecipeCollection {
    var id: UUID
    var name: String
    var tintHex: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var recipes: [SavedRecipe]?

    init(name: String, tintHex: String = "#20A465") {
        self.id = UUID()
        self.name = name
        self.tintHex = tintHex
        self.createdAt = .now
        self.recipes = []
    }
}
