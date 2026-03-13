//
//  RecipeAPIService.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-17.
//

import Foundation

enum APIError: Error {
    case badURL
    case noInternet
    case badResponse
    case noData
    case decodingFailed
}

class RecipeAPIService {
    static let shared = RecipeAPIService()
    private let baseURL = "https://www.themealdb.com/api/json/v2/65232507"

    func ingredientImageURL(name: String, size: String = "small") -> URL? {
        let safeName = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()

        return URL(string: "https://www.themealdb.com/images/ingredients/\(safeName)-\(size).png")
    }

    func searchByOneIngredient(name: String) async throws -> [RecipeSummary] {
        let safeName = name.replacingOccurrences(of: " ", with: "_")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        guard let url = URL(string: "\(baseURL)/filter.php?i=\(safeName)") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(RecipeSearchResponse.self, from: data)
        return result.meals ?? []
    }

    func searchByManyIngredients(ingredientNames: [String]) async throws -> [RecipeSummaryWithScore] {
        let joined = ingredientNames
            .map { $0.replacingOccurrences(of: " ", with: "_") }
            .joined(separator: ",")

        guard let encoded = joined.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/filter.php?i=\(encoded)") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(RecipeSearchResponse.self, from: data)
        let meals = result.meals ?? []

        return meals.map { recipe in
            RecipeSummaryWithScore(
                id: recipe.id,
                name: recipe.name,
                pictureURL: recipe.pictureURL,
                matchScore: ingredientNames.count
            )
        }
    }

    func getRecipeDetails(recipeID: String) async throws -> RecipeDetails {
        guard let url = URL(string: "\(baseURL)/lookup.php?i=\(recipeID)") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(RecipeDetailsResponse.self, from: data)
        guard let meal = result.meals?.first else {
            throw APIError.noData
        }
        return meal
    }

    func getRandomRecipe() async throws -> RecipeDetails {
        guard let url = URL(string: "\(baseURL)/random.php") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(RecipeDetailsResponse.self, from: data)
        guard let meal = result.meals?.first else {
            throw APIError.noData
        }
        return meal
    }

    func getLatestMeals() async throws -> [RecipeDetails] {
        guard let url = URL(string: "\(baseURL)/latest.php") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(RecipeDetailsResponse.self, from: data)
        return result.meals ?? []
    }

    func get10RandomMeals() async throws -> [RecipeDetails] {
        guard let url = URL(string: "\(baseURL)/randomselection.php") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(RecipeDetailsResponse.self, from: data)
        return result.meals ?? []
    }

    func getAllIngredients() async throws -> [IngredientOption] {
        guard let url = URL(string: "\(baseURL)/list.php?i=list") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(IngredientListResponse.self, from: data)
        return result.meals ?? []
    }

    func searchByName(name: String) async throws -> [RecipeDetails] {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search.php?s=\(encoded)") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(RecipeDetailsResponse.self, from: data)
        return result.meals ?? []
    }

    func searchByFirstLetter(_ letter: String) async throws -> [RecipeSummary] {
        let trimmed = letter.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let initial = trimmed.first?.lowercased(),
              let encoded = initial.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search.php?f=\(encoded)") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(RecipeSearchResponse.self, from: data)
        return result.meals ?? []
    }

    func getFullRecipeDetails(recipeID: String) async throws -> RecipeDetails {
        return try await getRecipeDetails(recipeID: recipeID)
    }

    func searchRecipeByName(name: String) async throws -> [RecipeDetails] {
        return try await searchByName(name: name)
    }

    func searchRecipesByMultipleIngredients(ingredientNames: [String]) async throws -> [RecipeSummaryWithScore] {
        return try await searchByManyIngredients(ingredientNames: ingredientNames)
    }

    func searchRecipesByOneIngredient(ingredientName: String) async throws -> [RecipeSummary] {
        return try await searchByOneIngredient(name: ingredientName)
    }

    func getAllCategories() async throws -> [MealCategory] {
        guard let url = URL(string: "\(baseURL)/categories.php") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(MealCategoryResponse.self, from: data)
        return result.categories ?? []
    }

    func getAllAreas() async throws -> [MealArea] {
        guard let url = URL(string: "\(baseURL)/list.php?a=list") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(MealAreaResponse.self, from: data)
        return result.meals ?? []
    }

    func getRecipesByCategory(category: String) async throws -> [RecipeSummary] {
        guard let encoded = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/filter.php?c=\(encoded)") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(RecipeSearchResponse.self, from: data)
        return result.meals ?? []
    }

    func getRecipesByArea(area: String) async throws -> [RecipeSummary] {
        guard let encoded = area.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/filter.php?a=\(encoded)") else {
            throw APIError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.badResponse
        }

        let result = try JSONDecoder().decode(RecipeSearchResponse.self, from: data)
        return result.meals ?? []
    }

    func getRecipesByFirstLetter(_ letter: String) async throws -> [RecipeSummary] {
        try await searchByFirstLetter(letter)
    }
}
