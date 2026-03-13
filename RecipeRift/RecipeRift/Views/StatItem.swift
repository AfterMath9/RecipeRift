
//
//  StatItem.swift
//  RecipeRift
//

import SwiftUI

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color.opacity(0.14))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.recipeRounded(24, weight: .bold))
                    .foregroundColor(.primaryText)
                Text(title)
                    .font(.recipeRounded(13, weight: .medium))
                    .foregroundColor(.subtleText)
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .softCard(cornerRadius: 22)
    }
}
