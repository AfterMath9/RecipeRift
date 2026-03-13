//
//  EditIngredientSheet.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-21.
//

import SwiftUI

struct EditIngredientSheet: View {
    @Environment(\.dismiss) var dismiss

    var viewModel: MyKitchenViewModel
    var ingredient: KitchenIngredient

    @State private var name: String = ""
    @State private var category: String = "Protein"
    @State private var quantity: String = ""
    @State private var hasExpiration: Bool = false
    @State private var expirationDate: Date = Date()

    let categories = ["Protein", "Vegetable", "Grain", "Dairy", "Pantry", "Spice"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Ingredient Details")) {
                    TextField("Name", text: $name)

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
            .navigationTitle("Edit Ingredient")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !name.isEmpty {
                            ingredient.name = name
                            ingredient.category = category
                            ingredient.howMuch = quantity.isEmpty ? nil : quantity
                            ingredient.expiresOn = hasExpiration ? expirationDate : nil
                            viewModel.updateIngredient(ingredient)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = ingredient.name
                category = ingredient.category
                quantity = ingredient.howMuch ?? ""
                if let expiry = ingredient.expiresOn {
                    hasExpiration = true
                    expirationDate = expiry
                }
            }
        }
    }
}
