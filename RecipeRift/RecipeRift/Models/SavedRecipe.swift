//
//  SavedRecipe.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-17.
//

import SwiftData
import Foundation

@Model
class SavedRecipe {
    var id: String
    var recipeName: String
    var pictureURL: String?
    var cuisineType: String?
    var categoryType: String?
    
    var cookingSteps: String
    var videoLink: String?
    
    var ingredientsJSON: String
    var measurementsJSON: String
    
    var isBookmarked: Bool
    var hasCooked: Bool
    var userRating: Int?
    var userNotes: String?
    var userPhotoData: Data?
    var whenBookmarked: Date?
    var whenFirstCooked: Date?
    var howManyTimesMade: Int
    var lastViewedAt: Date?
    var viewCount: Int
    var personalDifficulty: String?
    var personalPrepMinutes: Int?
    var personalServings: Int?
    
    @Relationship(deleteRule: .nullify)
    var ingredientsUsed: [KitchenIngredient]?
    
    @Relationship(deleteRule: .cascade)
    var cookLogs: [CookLog]?
    
    @Relationship(deleteRule: .nullify, inverse: \RecipeCollection.recipes)
    var collections: [RecipeCollection]?
    
    init(id: String, recipeName: String, pictureURL: String?, cuisineType: String?, categoryType: String?, cookingSteps: String, videoLink: String?, ingredientsJSON: String, measurementsJSON: String) {
        self.id = id
        self.recipeName = recipeName
        self.pictureURL = pictureURL
        self.cuisineType = cuisineType
        self.categoryType = categoryType
        self.cookingSteps = cookingSteps
        self.videoLink = videoLink
        self.ingredientsJSON = ingredientsJSON
        self.measurementsJSON = measurementsJSON
        
        self.isBookmarked = true
        self.hasCooked = false
        self.userRating = nil
        self.userNotes = nil
        self.userPhotoData = nil
        self.whenBookmarked = Date()
        self.whenFirstCooked = nil
        self.howManyTimesMade = 0
        self.lastViewedAt = nil
        self.viewCount = 0
        self.personalDifficulty = nil
        self.personalPrepMinutes = nil
        self.personalServings = nil
        self.ingredientsUsed = []
        self.cookLogs = []
        self.collections = []
    }
    
    func getIngredientsList() -> [String] {
        guard let data = ingredientsJSON.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return array
    }
    
    func getMeasurementsList() -> [String] {
        guard let data = measurementsJSON.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return array
    }

    func recordView(at date: Date = Date()) {
        lastViewedAt = date
        viewCount += 1
    }
}
