
//
//  CategoryCard.swift
//  RecipeRift
//

import SwiftUI

struct CategoryCard: View {
    let category: MealCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: category.pictureURL ?? "")) { phase in
                if let img = phase.image {
                    img.resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    LinearGradient(
                        colors: [Color.brandGreenLight, Color.softIvory],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        Image(systemName: "fork.knife")
                            .foregroundColor(.brandGreen)
                            .font(.title2)
                    )
                }
            }
            .frame(width: 122, height: 122)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            Text(category.name)
                .font(.recipeRounded(15, weight: .bold))
                .foregroundColor(.primaryText)
                .lineLimit(2)
        }
        .frame(width: 122, alignment: .leading)
    }
}
