
//
//  StatisticsCard.swift
//  RecipeRift
//

import SwiftUI

struct StatisticsCard: View {
    let bookmarked: Int
    let cooked: Int
    let favoriteCuisine: String?
    @State private var shown = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatItem(title: "Bookmarked", value: "\(bookmarked)", icon: "bookmark.fill", color: .brandGreen)
                StatItem(title: "Cooked",     value: "\(cooked)",     icon: "flame.fill",    color: .orange)
            }
            if let cuisine = favoriteCuisine {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill").foregroundColor(.brandGreen).font(.caption)
                    Text("Fav Cuisine: \(cuisine)").font(.caption).fontWeight(.semibold)
                }
                .padding(.vertical, 8).padding(.horizontal, 14)
                .background(Color.brandGreenLight)
                .foregroundColor(.brandGreen)
                .clipShape(Capsule())
            }
        }
        .opacity(shown ? 1 : 0)
        .offset(y: shown ? 0 : 14)
        .onAppear { withAnimation(.easeOut(duration: 0.4)) { shown = true } }
    }
}
