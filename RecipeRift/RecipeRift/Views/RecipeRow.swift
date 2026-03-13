
//
//  RecipeRow.swift
//  RecipeRift
//

import SwiftUI

struct RecipeRow: View {
    let recipe: SavedRecipe

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: recipe.pictureURL ?? "")) { phase in
                if let img = phase.image {
                    img.resizable().aspectRatio(contentMode: .fill)
                } else {
                    LinearGradient(
                        colors: [Color.brandGreenLight, Color.softIvory],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(Image(systemName: "photo").foregroundColor(.brandGreen.opacity(0.4)))
                }
            }
            .frame(width: 96, height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.recipeName)
                    .font(.recipeRounded(21, weight: .bold))
                    .foregroundColor(.primaryText)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    if let cuisine = recipe.cuisineType {
                        Text(cuisine)
                            .font(.recipeRounded(12, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.brandGreenLight)
                            .foregroundColor(.brandGreen)
                            .clipShape(Capsule())
                    }
                    if recipe.hasCooked {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.brandGreen)
                    }
                }

                Text(recipe.categoryType ?? "Saved recipe")
                    .font(.recipeRounded(14, weight: .medium))
                    .foregroundStyle(Color.subtleText)
                    .lineLimit(1)
            }
            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.subtleText)
        }
        .padding(18)
        .softCard(cornerRadius: 26)
        .padding(.vertical, 4)
    }
}
