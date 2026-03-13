//
//  AddIngredientSheet.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-18.
//

import SwiftUI

struct AddIngredientSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var viewModel: MyKitchenViewModel
    
    @State private var name: String = ""
    @State private var category: String = "Protein"
    @State private var quantity: String = ""
    @State private var expirationDate: Date = Date()
    @State private var hasExpiration: Bool = false
    
    let categories = ["Protein", "Vegetable", "Grain", "Dairy", "Pantry", "Spice"]
    
    var body: some View {
        NavigationStack {
            Form {

                Section(header: Text("Ingredient Details")) {
                    TextField("Name (e.g., Chicken)", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    TextField("Quantity (Optional)", text: $quantity)
                }
                
                Section(header: Text("Expiration")) {
                    Toggle("Has Expiration Date", isOn: $hasExpiration)
                    
                    if hasExpiration {
                        DatePicker("Expires On", selection: $expirationDate, displayedComponents: .date)
                    }
                }
            }
            .tint(.brandGreen)
            .navigationTitle("Add Ingredient")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if !name.isEmpty {
                            viewModel.addNewIngredient(
                                name: name,
                                category: category,
                                howMuch: quantity.isEmpty ? nil : quantity,
                                expiresOn: hasExpiration ? expirationDate : nil
                            )
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
