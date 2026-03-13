//
//  MyKitchenViewModel.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-18.
//

import SwiftUI
import SwiftData

@Observable
class MyKitchenViewModel {
    var allIngredients: [KitchenIngredient] = []
    var searchText: String = ""
    var selectedCategory: String = "All"
    var showingAddSheet: Bool = false
    
    private var databaseContext: ModelContext
    
    init(databaseContext: ModelContext) {
        self.databaseContext = databaseContext
        loadAllIngredients()
    }
    
    func loadAllIngredients() {
        let request = FetchDescriptor<KitchenIngredient>(
            sortBy: [SortDescriptor(\.name)]
        )
        allIngredients = (try? databaseContext.fetch(request)) ?? []
    }
    
    func addNewIngredient(name: String, category: String, howMuch: String?, expiresOn: Date?) {
        let newIngredient = KitchenIngredient(
            name: name,
            category: category,
            howMuch: howMuch,
            expiresOn: expiresOn
        )
        databaseContext.insert(newIngredient)
        saveChanges()
        loadAllIngredients()
    }
    
    func deleteIngredient(_ ingredient: KitchenIngredient) {
        databaseContext.delete(ingredient)
        saveChanges()
        loadAllIngredients()
    }
    
    func updateIngredient(_ ingredient: KitchenIngredient) {
        saveChanges()
        loadAllIngredients()
    }
    
    func toggleSelection(_ ingredient: KitchenIngredient) {
        ingredient.isSelected.toggle()
        saveChanges()
    }
    
    func getSelectedIngredients() -> [KitchenIngredient] {
        return allIngredients.filter { $0.isSelected }
    }
    
    func getFilteredIngredients() -> [KitchenIngredient] {
        var filtered = allIngredients
        
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    func getIngredientsThatWillExpireSoon() -> [KitchenIngredient] {
        return allIngredients.filter { $0.isExpiringSoon }
    }
    
    func clearAllSelections() {
        for ingredient in allIngredients {
            ingredient.isSelected = false
        }
        saveChanges()
    }
    
    private func saveChanges() {
        try? databaseContext.save()
    }
}
