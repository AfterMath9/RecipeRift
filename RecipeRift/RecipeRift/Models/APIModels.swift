//
//  APIModels.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-17.
//

import Foundation

struct RecipeSummary: Codable, Identifiable {
    let id: String
    let name: String
    let pictureURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case pictureURL = "strMealThumb"
    }
}

struct RecipeSummaryWithScore: Identifiable {
    let id: String
    let name: String
    let pictureURL: String?
    let matchScore: Int
}

struct RecipeDetails: Codable, Identifiable {
    let id: String
    let recipeName: String
    let categoryType: String?
    let cuisineType: String?
    let cookingSteps: String?
    let pictureURL: String?
    let videoLink: String?
    
    let ingredient1: String?
    let ingredient2: String?
    let ingredient3: String?
    let ingredient4: String?
    let ingredient5: String?
    let ingredient6: String?
    let ingredient7: String?
    let ingredient8: String?
    let ingredient9: String?
    let ingredient10: String?
    let ingredient11: String?
    let ingredient12: String?
    let ingredient13: String?
    let ingredient14: String?
    let ingredient15: String?
    let ingredient16: String?
    let ingredient17: String?
    let ingredient18: String?
    let ingredient19: String?
    let ingredient20: String?
    
    let measure1: String?
    let measure2: String?
    let measure3: String?
    let measure4: String?
    let measure5: String?
    let measure6: String?
    let measure7: String?
    let measure8: String?
    let measure9: String?
    let measure10: String?
    let measure11: String?
    let measure12: String?
    let measure13: String?
    let measure14: String?
    let measure15: String?
    let measure16: String?
    let measure17: String?
    let measure18: String?
    let measure19: String?
    let measure20: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case recipeName = "strMeal"
        case categoryType = "strCategory"
        case cuisineType = "strArea"
        case cookingSteps = "strInstructions"
        case pictureURL = "strMealThumb"
        case videoLink = "strYoutube"
        
        case ingredient1 = "strIngredient1"
        case ingredient2 = "strIngredient2"
        case ingredient3 = "strIngredient3"
        case ingredient4 = "strIngredient4"
        case ingredient5 = "strIngredient5"
        case ingredient6 = "strIngredient6"
        case ingredient7 = "strIngredient7"
        case ingredient8 = "strIngredient8"
        case ingredient9 = "strIngredient9"
        case ingredient10 = "strIngredient10"
        case ingredient11 = "strIngredient11"
        case ingredient12 = "strIngredient12"
        case ingredient13 = "strIngredient13"
        case ingredient14 = "strIngredient14"
        case ingredient15 = "strIngredient15"
        case ingredient16 = "strIngredient16"
        case ingredient17 = "strIngredient17"
        case ingredient18 = "strIngredient18"
        case ingredient19 = "strIngredient19"
        case ingredient20 = "strIngredient20"
        
        case measure1 = "strMeasure1"
        case measure2 = "strMeasure2"
        case measure3 = "strMeasure3"
        case measure4 = "strMeasure4"
        case measure5 = "strMeasure5"
        case measure6 = "strMeasure6"
        case measure7 = "strMeasure7"
        case measure8 = "strMeasure8"
        case measure9 = "strMeasure9"
        case measure10 = "strMeasure10"
        case measure11 = "strMeasure11"
        case measure12 = "strMeasure12"
        case measure13 = "strMeasure13"
        case measure14 = "strMeasure14"
        case measure15 = "strMeasure15"
        case measure16 = "strMeasure16"
        case measure17 = "strMeasure17"
        case measure18 = "strMeasure18"
        case measure19 = "strMeasure19"
        case measure20 = "strMeasure20"
    }
    
    func getAllIngredients() -> [String] {
        let allIngredients = [
            ingredient1, ingredient2, ingredient3, ingredient4, ingredient5,
            ingredient6, ingredient7, ingredient8, ingredient9, ingredient10,
            ingredient11, ingredient12, ingredient13, ingredient14, ingredient15,
            ingredient16, ingredient17, ingredient18, ingredient19, ingredient20
        ]
        
        return allIngredients.compactMap { ingredient in
            guard let ing = ingredient, !ing.isEmpty, ing != " " else { return nil }
            return ing.trimmingCharacters(in: .whitespaces)
        }
    }
    
    func getAllMeasurements() -> [String] {
        let allMeasures = [
            measure1, measure2, measure3, measure4, measure5,
            measure6, measure7, measure8, measure9, measure10,
            measure11, measure12, measure13, measure14, measure15,
            measure16, measure17, measure18, measure19, measure20
        ]
        
        return allMeasures.compactMap { measure in
            guard let m = measure, !m.isEmpty, m != " " else { return nil }
            return m.trimmingCharacters(in: .whitespaces)
        }
    }
}

struct IngredientOption: Codable, Identifiable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "idIngredient"
        case name = "strIngredient"
    }
}

struct RecipeSearchResponse: Codable {
    let meals: [RecipeSummary]?
}

struct RecipeDetailsResponse: Codable {
    let meals: [RecipeDetails]?
}

struct IngredientListResponse: Codable {
    let meals: [IngredientOption]?
}

struct MealCategory: Codable, Identifiable {
    let id: String
    let name: String
    let pictureURL: String?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id = "idCategory"
        case name = "strCategory"
        case pictureURL = "strCategoryThumb"
        case description = "strCategoryDescription"
    }
}

struct MealArea: Decodable, Identifiable {
    let id: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case area = "strArea"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let area = try container.decode(String.self, forKey: .area)
        self.id = area
        self.name = area
    }
}

struct MealCategoryResponse: Codable {
    let categories: [MealCategory]?
}

struct MealAreaResponse: Decodable {
    let meals: [MealArea]?
}
