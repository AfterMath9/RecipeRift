//
//  RecipeFinderViewModel.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-18.
//

import SwiftUI
import SwiftData

nonisolated
func countIngredientMatches(recipeIngredients: [String], userIngredients: [String]) -> Int {
    let userSet = userIngredients.map { $0.lowercased() }
    return recipeIngredients.filter { recipeIng in
        let lower = recipeIng.lowercased()
        return userSet.contains(where: { lower.contains($0) || $0.contains(lower) })
    }.count
}

@Observable
class RecipeFinderViewModel {
    var foundRecipes: [RecipeSummaryWithScore] = []
    var isSearching: Bool = false
    var errorMessage: String? = nil
    var pickedIngredients: [String] = []

    private var db: ModelContext

    init(databaseContext: ModelContext) {
        self.db = databaseContext
    }

    func searchByIngredients(names: [String]) async {
        guard !names.isEmpty else {
            errorMessage = "No ingredients selected."
            return
        }

        isSearching = true
        errorMessage = nil
        foundRecipes = []
        pickedIngredients = names

        do {
            foundRecipes = try await RecipeAPIService.shared.searchByManyIngredients(ingredientNames: names)
        } catch {
            errorMessage = "Could not find recipes. Check your connection."
        }

        isSearching = false
    }

    func searchByName(query: String) async {
        guard !query.isEmpty else { return }

        isSearching = true
        errorMessage = nil
        foundRecipes = []

        do {
            let details = try await RecipeAPIService.shared.searchByName(name: query)
            foundRecipes = details.map { d in
                RecipeSummaryWithScore(id: d.id, name: d.recipeName, pictureURL: d.pictureURL, matchScore: 0)
            }.sorted { $0.name < $1.name }
        } catch {
            errorMessage = "Could not search recipes. Check your connection."
        }

        isSearching = false
    }

    func loadRandomSuggestions(limit: Int = 5) async {
        isSearching = true
        errorMessage = nil
        foundRecipes = []

        do {
            let meals = try await RecipeAPIService.shared.get10RandomMeals()
            foundRecipes = Array(meals.prefix(limit)).map { d in
                RecipeSummaryWithScore(id: d.id, name: d.recipeName, pictureURL: d.pictureURL, matchScore: 0)
            }
        } catch {
            print("Random suggestions failed: \(error)")
        }

        isSearching = false
    }

    func loadSuggestionsForIngredients(userIngredients: [String], limit: Int = 3) async {
        guard !userIngredients.isEmpty else {
            await loadRandomSuggestions(limit: limit)
            return
        }

        isSearching = true
        errorMessage = nil
        foundRecipes = []

        do {
            let sample = Array(userIngredients.shuffled().prefix(3))
            var gathered: [RecipeSummaryWithScore] = []

            try await withThrowingTaskGroup(of: [RecipeSummaryWithScore].self) { group in
                for ingredient in sample {
                    group.addTask {
                        (try? await RecipeAPIService.shared.searchByManyIngredients(ingredientNames: [ingredient])) ?? []
                    }
                }
                for try await batch in group {
                    for recipe in batch where !gathered.contains(where: { $0.id == recipe.id }) {
                        gathered.append(recipe)
                    }
                }
            }

            var top = Array(gathered.sorted { $0.matchScore > $1.matchScore }.prefix(limit))

            top = await recalculateRealMatchScores(recipes: top, userIngredients: userIngredients)

            if top.count < limit {
                let needed = limit - top.count
                var extras: [RecipeSummaryWithScore] = []
                try await withThrowingTaskGroup(of: RecipeDetails?.self) { group in
                    for _ in 0..<needed {
                        group.addTask { try? await RecipeAPIService.shared.getRandomRecipe() }
                    }
                    for try await d in group {
                        if let d = d, !top.contains(where: { $0.id == d.id }) {
                            let score = countIngredientMatches(recipeIngredients: d.getAllIngredients(), userIngredients: userIngredients)
                            extras.append(RecipeSummaryWithScore(
                                id: d.id, name: d.recipeName, pictureURL: d.pictureURL, matchScore: score
                            ))
                        }
                    }
                }
                top.append(contentsOf: extras.prefix(needed))
            }

            foundRecipes = top
        } catch {
            await loadRandomSuggestions(limit: limit)
        }

        isSearching = false
    }

    nonisolated private func recalculateRealMatchScores(recipes: [RecipeSummaryWithScore], userIngredients: [String]) async -> [RecipeSummaryWithScore] {
        var updated: [RecipeSummaryWithScore] = []

        await withTaskGroup(of: RecipeSummaryWithScore.self) { group in
            for recipe in recipes {
                let recipeID = recipe.id
                let recipeName = recipe.name
                let recipePic = recipe.pictureURL
                group.addTask {
                    if let details = try? await RecipeAPIService.shared.getRecipeDetails(recipeID: recipeID) {
                        // In case the compiler infers main isolation for this closure, hop only for the pure accessor.
                        let ingredients: [String] = await MainActor.run {
                            details.getAllIngredients()
                        }
                        let score = countIngredientMatches(
                            recipeIngredients: ingredients,
                            userIngredients: userIngredients
                        )
                        return RecipeSummaryWithScore(id: recipeID, name: recipeName, pictureURL: recipePic, matchScore: score)
                    }
                    return RecipeSummaryWithScore(id: recipeID, name: recipeName, pictureURL: recipePic, matchScore: 0)
                }
            }
            for await result in group {
                updated.append(result)
            }
        }

        return updated.sorted { $0.matchScore > $1.matchScore }
    }

    func sortByBestMatch() {
        foundRecipes.sort { $0.matchScore > $1.matchScore }
    }

    func sortByName() {
        foundRecipes.sort { $0.name < $1.name }
    }

    func isAlreadySaved(recipeID: String) -> Bool {
        let descriptor = FetchDescriptor<SavedRecipe>(predicate: #Predicate { $0.id == recipeID })
        return (try? db.fetchCount(descriptor)) ?? 0 > 0
    }

    func searchForRecipes(withIngredients names: [String]) async {
        await searchByIngredients(names: names)
    }

    func searchForRecipesByName(query: String) async {
        await searchByName(query: query)
    }

    func loadIngredientSuggestions(ingredientNames: [String], limit: Int = 3) async {
        await loadSuggestionsForIngredients(userIngredients: ingredientNames, limit: limit)
    }

    func isRecipeAlreadySaved(recipeID: String) -> Bool {
        return isAlreadySaved(recipeID: recipeID)
    }

    func sortRecipesByBestMatch() { sortByBestMatch() }
    func sortRecipesByName() { sortByName() }
}
