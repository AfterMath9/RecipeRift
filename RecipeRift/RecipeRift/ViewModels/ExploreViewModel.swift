//
//  ExploreViewModel.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-21.
//

import SwiftUI

@Observable
class ExploreViewModel {
    var categories: [MealCategory] = []
    var areas: [MealArea] = []
    var recipes: [RecipeSummary] = []
    var latestMeals: [RecipeDetails] = []

    var isLoadingCategories = false
    var isLoadingAreas = false
    var isLoadingRecipes = false
    var isLoadingLatest = false

    var errorMessage: String? = nil

    var selectedCategory: String? = nil
    var selectedArea: String? = nil
    var selectedLetter: String? = nil

    func loadLatestMeals() async {
        isLoadingLatest = true
        do {
            latestMeals = try await RecipeAPIService.shared.getLatestMeals()
        } catch {
            print("Could not load latest meals: \(error)")
        }
        isLoadingLatest = false
    }

    func loadCategories() async {
        isLoadingCategories = true
        errorMessage = nil

        do {
            categories = try await RecipeAPIService.shared.getAllCategories()
        } catch {
            errorMessage = "Could not load categories."
        }

        isLoadingCategories = false
    }

    func loadAreas() async {
        isLoadingAreas = true
        errorMessage = nil

        do {
            areas = try await RecipeAPIService.shared.getAllAreas()
        } catch {
            errorMessage = "Could not load cuisines."
        }

        isLoadingAreas = false
    }

    func showRecipesFor(category: String) async {
        selectedCategory = category
        selectedArea = nil
        selectedLetter = nil
        isLoadingRecipes = true
        errorMessage = nil
        recipes = []

        do {
            recipes = try await RecipeAPIService.shared.getRecipesByCategory(category: category)
        } catch {
            errorMessage = "Could not load recipes for \(category)."
        }

        isLoadingRecipes = false
    }

    func showRecipesFor(area: String) async {
        selectedArea = area
        selectedCategory = nil
        selectedLetter = nil
        isLoadingRecipes = true
        errorMessage = nil
        recipes = []

        do {
            recipes = try await RecipeAPIService.shared.getRecipesByArea(area: area)
        } catch {
            errorMessage = "Could not load recipes from \(area)."
        }

        isLoadingRecipes = false
    }

    func showRecipesFor(firstLetter: String) async {
        selectedLetter = firstLetter
        selectedCategory = nil
        selectedArea = nil
        isLoadingRecipes = true
        errorMessage = nil
        recipes = []

        do {
            recipes = try await RecipeAPIService.shared.getRecipesByFirstLetter(firstLetter)
        } catch {
            errorMessage = "Could not load recipes for \(firstLetter.uppercased())."
        }

        isLoadingRecipes = false
    }

    func clearRecipes() {
        recipes = []
        selectedCategory = nil
        selectedArea = nil
        selectedLetter = nil
    }
}
