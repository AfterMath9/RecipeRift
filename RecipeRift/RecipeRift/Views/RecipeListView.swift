
//
//  RecipeListView.swift
//  RecipeRift
//

import SwiftUI

struct RecipeListView: View {
    let title: String
    var vm: ExploreViewModel
    let loadAction: () async -> Void
    @State private var loaded = false

    var body: some View {
        ZStack {
            Color.pageSurface.ignoresSafeArea()

            Group {
                if vm.isLoadingRecipes {
                    VStack(spacing: 14) {
                        ProgressView().tint(.brandGreen).scaleEffect(1.3)
                        Text("Loading…").font(.recipeRounded(15, weight: .medium)).foregroundColor(.subtleText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.recipes.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "fork.knife").font(.system(size: 44)).foregroundColor(.brandGreen.opacity(0.3))
                        Text("No recipes found").font(.recipeRounded(17, weight: .semibold)).foregroundColor(.subtleText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(vm.recipes.enumerated()), id: \.element.id) { index, recipe in
                                NavigationLink { RecipeDetailView(recipeID: recipe.id) } label: {
                                    ListRecipeCard(recipe: recipe, index: index)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .task {
            if !loaded {
                loaded = true
                await loadAction()
            }
        }
    }
}

private struct ListRecipeCard: View {
    let recipe: RecipeSummary
    let index: Int
    @State private var shown = false

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

            Text(recipe.name)
                .font(.recipeRounded(21, weight: .bold))
                .foregroundColor(.primaryText)
                .lineLimit(2)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.subtleText)
        }
        .padding(18)
        .softCard(cornerRadius: 26)
        .opacity(shown ? 1 : 0)
        .offset(y: shown ? 0 : 12)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(index) * 0.06)) { shown = true }
        }
    }
}
