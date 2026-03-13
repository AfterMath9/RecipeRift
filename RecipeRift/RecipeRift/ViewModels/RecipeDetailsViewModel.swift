//
//  RecipeDetailsViewModel.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-18.
//

import SwiftUI
import SwiftData

@Observable
class RecipeDetailsViewModel {
    var fullRecipeDetails: RecipeDetails? = nil
    var savedRecipe: SavedRecipe? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var userKitchenIngredients: [KitchenIngredient] = []

    private let apiService = RecipeAPIService.shared
    private var databaseContext: ModelContext
    private var recipeID: String

    init(databaseContext: ModelContext, recipeID: String) {
        self.databaseContext = databaseContext
        self.recipeID = recipeID
        loadUserIngredients()
        checkIfRecipeIsSaved()
    }

    func loadRecipeFromAPI() async {
        isLoading = true
        errorMessage = nil

        do {
            fullRecipeDetails = try await apiService.getFullRecipeDetails(recipeID: recipeID)
            recordRecentView()
        } catch {
            errorMessage = "Could not load recipe details. Try again."
        }

        isLoading = false
    }

    func loadUserIngredients() {
        let request = FetchDescriptor<KitchenIngredient>()
        userKitchenIngredients = (try? databaseContext.fetch(request)) ?? []
    }

    func checkIfRecipeIsSaved() {
        let request = FetchDescriptor<SavedRecipe>(predicate: #Predicate { $0.id == recipeID })
        savedRecipe = try? databaseContext.fetch(request).first
    }

    func toggleBookmark() {
        if savedRecipe != nil {
            removeBookmark()
        } else {
            addBookmark()
        }
    }

    func addBookmark() {
        guard let details = fullRecipeDetails else { return }

        if let existing = try? databaseContext.fetch(FetchDescriptor<SavedRecipe>(predicate: #Predicate { $0.id == details.id })).first {
            savedRecipe = existing
            return
        }

        let ingredients = details.getAllIngredients()
        let measurements = details.getAllMeasurements()

        let ingredientsJSON = (try? JSONEncoder().encode(ingredients)) ?? Data()
        let measurementsJSON = (try? JSONEncoder().encode(measurements)) ?? Data()

        let newSavedRecipe = SavedRecipe(
            id: details.id,
            recipeName: details.recipeName,
            pictureURL: details.pictureURL,
            cuisineType: details.cuisineType,
            categoryType: details.categoryType,
            cookingSteps: details.cookingSteps ?? "",
            videoLink: details.videoLink,
            ingredientsJSON: String(data: ingredientsJSON, encoding: .utf8) ?? "[]",
            measurementsJSON: String(data: measurementsJSON, encoding: .utf8) ?? "[]"
        )

        databaseContext.insert(newSavedRecipe)
        try? databaseContext.save()
        savedRecipe = newSavedRecipe
    }

    func removeBookmark() {
        guard let saved = savedRecipe else { return }
        databaseContext.delete(saved)
        try? databaseContext.save()
        savedRecipe = nil
    }

    func markRecipeAsCooked() {
        let saved = ensureSavedRecipe()
        guard let saved else { return }

        saved.hasCooked = true
        saved.howManyTimesMade += 1

        if saved.whenFirstCooked == nil {
            saved.whenFirstCooked = Date()
        }

        let log = CookLog(
            rating: saved.userRating,
            notes: saved.userNotes,
            photoData: saved.userPhotoData,
            personalDifficulty: saved.personalDifficulty,
            personalPrepMinutes: saved.personalPrepMinutes,
            personalServings: saved.personalServings,
            recipe: saved
        )
        databaseContext.insert(log)
        saved.cookLogs?.append(log)

        try? databaseContext.save()
    }

    func saveUserRating(_ rating: Int) {
        guard let saved = ensureSavedRecipe() else { return }
        saved.userRating = rating
        try? databaseContext.save()
    }

    func saveUserNotes(_ notes: String) {
        guard let saved = ensureSavedRecipe() else { return }
        saved.userNotes = notes
        try? databaseContext.save()
    }

    func saveUserPhoto(_ imageData: Data) {
        guard let saved = ensureSavedRecipe() else { return }
        saved.userPhotoData = imageData
        try? databaseContext.save()
    }

    func savePersonalDifficulty(_ difficulty: String) {
        guard let saved = ensureSavedRecipe() else { return }
        saved.personalDifficulty = difficulty
        try? databaseContext.save()
    }

    func savePersonalPrepMinutes(_ minutes: Int) {
        guard let saved = ensureSavedRecipe() else { return }
        saved.personalPrepMinutes = minutes
        try? databaseContext.save()
    }

    func savePersonalServings(_ servings: Int) {
        guard let saved = ensureSavedRecipe() else { return }
        saved.personalServings = servings
        try? databaseContext.save()
    }

    func saveCookLogFromCurrentNotes() {
        guard let saved = ensureSavedRecipe() else { return }

        let log = CookLog(
            rating: saved.userRating,
            notes: saved.userNotes,
            photoData: saved.userPhotoData,
            personalDifficulty: saved.personalDifficulty,
            personalPrepMinutes: saved.personalPrepMinutes,
            personalServings: saved.personalServings,
            recipe: saved
        )
        databaseContext.insert(log)
        saved.cookLogs?.append(log)
        try? databaseContext.save()
    }

    func getCookLogs() -> [CookLog] {
        guard let saved = savedRecipe else { return [] }
        let request = FetchDescriptor<CookLog>(
            sortBy: [SortDescriptor(\.cookedAt, order: .reverse)]
        )
        return ((try? databaseContext.fetch(request)) ?? []).filter { $0.recipe?.id == saved.id }
    }

    func getIngredientsThatUserHas() -> [String] {
        guard let details = fullRecipeDetails else { return [] }
        let recipeIngredients = details.getAllIngredients()
        let userIngredientNames = Set(userKitchenIngredients.map { $0.name.lowercased() })
        return recipeIngredients.filter { userIngredientNames.contains($0.lowercased()) }
    }

    func getIngredientsThatUserDoesNotHave() -> [String] {
        guard let details = fullRecipeDetails else { return [] }
        let recipeIngredients = details.getAllIngredients()
        let userIngredientNames = Set(userKitchenIngredients.map { $0.name.lowercased() })
        return recipeIngredients.filter { !userIngredientNames.contains($0.lowercased()) }
    }

    func getMissingIngredientPairs() -> [(String, String)] {
        guard let details = fullRecipeDetails else { return [] }
        let ingredients = details.getAllIngredients()
        let measures = details.getAllMeasurements()
        let userIngredientNames = Set(userKitchenIngredients.map { $0.name.lowercased() })

        return ingredients.enumerated().compactMap { index, ingredient in
            guard !userIngredientNames.contains(ingredient.lowercased()) else { return nil }
            let measure = index < measures.count ? measures[index] : ""
            return (ingredient, measure)
        }
    }

    func getAvailableIngredientPairs() -> [(String, String)] {
        guard let details = fullRecipeDetails else { return [] }
        let ingredients = details.getAllIngredients()
        let measures = details.getAllMeasurements()
        let userIngredientNames = Set(userKitchenIngredients.map { $0.name.lowercased() })

        return ingredients.enumerated().compactMap { index, ingredient in
            guard userIngredientNames.contains(ingredient.lowercased()) else { return nil }
            let measure = index < measures.count ? measures[index] : ""
            return (ingredient, measure)
        }
    }

    func canUserMakeThisRecipe() -> Bool {
        return getIngredientsThatUserDoesNotHave().isEmpty
    }

    func addMissingIngredientsToGroceryList() {
        guard let details = fullRecipeDetails else { return }
        let missingItems = getMissingIngredientPairs()
        let existingItems = (try? databaseContext.fetch(FetchDescriptor<GroceryListItem>())) ?? []

        for item in missingItems {
            let alreadyExists = existingItems.contains {
                !$0.isChecked &&
                $0.ingredientName.caseInsensitiveCompare(item.0) == .orderedSame &&
                $0.recipeID == details.id
            }

            if alreadyExists {
                continue
            }

            let groceryItem = GroceryListItem(
                ingredientName: item.0,
                quantity: item.1.isEmpty ? nil : item.1,
                recipeID: details.id,
                recipeName: details.recipeName
            )
            databaseContext.insert(groceryItem)
        }

        try? databaseContext.save()
    }

    func addMealPlanEntry(for date: Date, mealSlot: MealPlannerSlot, includeMissingIngredients: Bool) {
        guard let details = fullRecipeDetails else { return }

        let entry = MealPlanEntry(
            recipeID: details.id,
            recipeName: details.recipeName,
            recipeImageURL: details.pictureURL,
            date: Calendar.current.startOfDay(for: date),
            mealSlot: mealSlot.rawValue
        )
        databaseContext.insert(entry)

        if includeMissingIngredients {
            addMissingIngredientsToGroceryList()
        }

        try? databaseContext.save()
    }

    private func ensureSavedRecipe() -> SavedRecipe? {
        if savedRecipe == nil {
            addBookmark()
        }
        return savedRecipe
    }

    private func recordRecentView() {
        guard let details = fullRecipeDetails else { return }

        if let savedRecipe {
            savedRecipe.recordView()
        }

        let recentRequest = FetchDescriptor<RecentRecipe>(
            predicate: #Predicate { $0.recipeID == details.id }
        )

        if let existing = try? databaseContext.fetch(recentRequest).first {
            existing.recipeName = details.recipeName
            existing.pictureURL = details.pictureURL
            existing.cuisineType = details.cuisineType
            existing.viewedAt = .now
        } else {
            let recent = RecentRecipe(
                recipeID: details.id,
                recipeName: details.recipeName,
                pictureURL: details.pictureURL,
                cuisineType: details.cuisineType
            )
            databaseContext.insert(recent)
        }

        try? databaseContext.save()
    }
}
