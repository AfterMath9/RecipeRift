//
//  MyRecipesViewModel.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-18.
//

import SwiftUI
import SwiftData

@Observable
class MyRecipesViewModel {
    var allSavedRecipes: [SavedRecipe] = []
    var filteredRecipes: [SavedRecipe] = []
    var selectedTab: RecipeFilterTab = .bookmarked
    var searchText: String = ""
    
    private var databaseContext: ModelContext
    
    init(databaseContext: ModelContext) {
        self.databaseContext = databaseContext
        loadAllRecipes()
        applyFilters()
    }
    
    func loadAllRecipes() {
        let request = FetchDescriptor<SavedRecipe>(
            sortBy: [SortDescriptor(\.whenBookmarked, order: .reverse)]
        )
        allSavedRecipes = (try? databaseContext.fetch(request)) ?? []
    }
    
    func applyFilters() {
        var recipes = allSavedRecipes
        
        switch selectedTab {
        case .bookmarked:
            recipes = recipes.filter { $0.isBookmarked }
        case .cooked:
            recipes = recipes.filter { $0.hasCooked }
        case .all:
            break
        }
        
        if !searchText.isEmpty {
            recipes = recipes.filter { recipe in
                recipe.recipeName.localizedCaseInsensitiveContains(searchText) ||
                recipe.cuisineType?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        filteredRecipes = recipes
    }
    
    func deleteRecipe(_ recipe: SavedRecipe) {
        databaseContext.delete(recipe)
        try? databaseContext.save()
        loadAllRecipes()
        applyFilters()
    }
    
    func getTotalBookmarkedCount() -> Int {
        return allSavedRecipes.filter { $0.isBookmarked }.count
    }
    
    func getTotalCookedCount() -> Int {
        return allSavedRecipes.filter { $0.hasCooked }.count
    }
    
    func getFavoriteCuisine() -> String? {
        let cuisineCounts = Dictionary(grouping: allSavedRecipes.filter { $0.hasCooked }) { 
            $0.cuisineType ?? "Unknown"
        }
        return cuisineCounts.max { $0.value.count < $1.value.count }?.key
    }
    
    func getMostCookedRecipe() -> SavedRecipe? {
        return allSavedRecipes
            .filter { $0.hasCooked }
            .max { $0.howManyTimesMade < $1.howManyTimesMade }
    }
    
    func getRecipesUserCanMakeNow() -> [SavedRecipe] {
        let ingredientRequest = FetchDescriptor<KitchenIngredient>()
        let userIngredients = (try? databaseContext.fetch(ingredientRequest)) ?? []
        let userIngredientNames = Set(userIngredients.map { $0.name.lowercased() })
        
        return allSavedRecipes.filter { recipe in
            let recipeIngredients = recipe.getIngredientsList()
            let recipeIngredientNames = Set(recipeIngredients.map { $0.lowercased() })
            return recipeIngredientNames.isSubset(of: userIngredientNames)
        }
    }
    
    func getAverageRating() -> Double {
        let ratedRecipes = allSavedRecipes.compactMap { $0.userRating }
        guard !ratedRecipes.isEmpty else { return 0.0 }
        let sum = ratedRecipes.reduce(0, +)
        return Double(sum) / Double(ratedRecipes.count)
    }
}
