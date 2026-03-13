import SwiftUI
import SwiftData

struct CollectionPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("proPlan") private var proPlanRawValue = ProPlan.free.rawValue
    @Query(sort: \RecipeCollection.createdAt, order: .forward) private var collections: [RecipeCollection]

    let recipe: SavedRecipe
    @State private var newCollectionName = ""
    @State private var showingPaywall = false

    private var isPro: Bool { PremiumAccess.plan(from: proPlanRawValue).isPro }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageSurface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("New Collection")
                                .font(.recipeRounded(18, weight: .bold))
                                .foregroundStyle(Color.primaryText)

                            HStack(spacing: 10) {
                                TextField("Quick Meals", text: $newCollectionName)
                                    .font(.recipeRounded(16, weight: .medium))
                                    .autocorrectionDisabled()
                                Button("Add") {
                                    guard isPro else {
                                        showingPaywall = true
                                        return
                                    }
                                    let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else { return }
                                    let collection = RecipeCollection(name: trimmed)
                                    collection.recipes = [recipe]
                                    modelContext.insert(collection)
                                    recipe.collections = (recipe.collections ?? []) + [collection]
                                    newCollectionName = ""
                                    try? modelContext.save()
                                }
                                .font(.recipeRounded(14, weight: .bold))
                                .foregroundStyle(Color.brandGreen)
                            }
                            .padding(16)
                            .softField(cornerRadius: 20)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Collections")
                                .font(.recipeRounded(18, weight: .bold))
                                .foregroundStyle(Color.primaryText)

                            ForEach(collections) { collection in
                                Button {
                                    toggle(recipe: recipe, in: collection)
                                } label: {
                                    HStack {
                                        Text(collection.name)
                                            .font(.recipeRounded(16, weight: .bold))
                                            .foregroundStyle(Color.primaryText)
                                        Spacer()
                                        Image(systemName: contains(recipe: recipe, in: collection) ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 20))
                                            .foregroundStyle(contains(recipe: recipe, in: collection) ? Color.brandGreen : Color.subtleText)
                                    }
                                    .padding(16)
                                    .softCard(cornerRadius: 22)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                }
            }
            .navigationTitle("Collections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView(focusFeature: .unlimitedCollections)
            }
        }
    }

    private func contains(recipe: SavedRecipe, in collection: RecipeCollection) -> Bool {
        collection.recipes?.contains(where: { $0.id == recipe.id }) == true
    }

    private func toggle(recipe: SavedRecipe, in collection: RecipeCollection) {
        var collectionRecipes = collection.recipes ?? []
        var recipeCollections = recipe.collections ?? []

        if contains(recipe: recipe, in: collection) {
            collectionRecipes.removeAll { $0.id == recipe.id }
            recipeCollections.removeAll { $0.id == collection.id }
        } else {
            collectionRecipes.append(recipe)
            recipeCollections.append(collection)
        }

        collection.recipes = collectionRecipes
        recipe.collections = recipeCollections
        try? modelContext.save()
    }
}
