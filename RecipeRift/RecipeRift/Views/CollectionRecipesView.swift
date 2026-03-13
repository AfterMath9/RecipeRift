import SwiftUI

struct CollectionRecipesView: View {
    let collection: RecipeCollection

    private var recipes: [SavedRecipe] {
        (collection.recipes ?? []).sorted { $0.recipeName.localizedCaseInsensitiveCompare($1.recipeName) == .orderedAscending }
    }

    var body: some View {
        ZStack {
            Color.pageSurface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    summaryCard

                    if recipes.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(recipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipeID: recipe.id)) {
                                    RecipeRow(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(collection.name)
                .font(.recipeRounded(28, weight: .bold))
                .foregroundStyle(Color.primaryText)

            Text("\(recipes.count) saved recipe\(recipes.count == 1 ? "" : "s") in this collection")
                .font(.recipeRounded(15, weight: .medium))
                .foregroundStyle(Color.subtleText)

            HStack(spacing: 8) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.brandGreen)
                Text("Organize recipes your way")
                    .font(.recipeRounded(13, weight: .semibold))
                    .foregroundStyle(Color.primaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.brandGreenLight)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .softCard(cornerRadius: 28)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 42))
                .foregroundStyle(Color.brandGreen.opacity(0.35))
            Text("No recipes here yet")
                .font(.recipeRounded(22, weight: .bold))
                .foregroundStyle(Color.primaryText)
            Text("Open any recipe and add it to this collection.")
                .font(.recipeRounded(15, weight: .medium))
                .foregroundStyle(Color.subtleText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 70)
    }
}
