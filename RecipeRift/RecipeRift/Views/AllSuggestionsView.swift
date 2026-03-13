
//
//  AllSuggestionsView.swift
//  RecipeRift
//

import SwiftUI
import SwiftData

struct AllSuggestionsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm: RecipeFinderViewModel?
    let userIngredientNames: [String]

    var body: some View {
        ZStack {
            Color.pageSurface.ignoresSafeArea()

            Group {
                if let vm = vm {
                    if vm.isSearching {
                        VStack(spacing: 14) {
                            ProgressView().tint(.brandGreen).scaleEffect(1.3)
                            Text("Loading recipes…").font(.recipeRounded(15, weight: .medium)).foregroundColor(.subtleText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if vm.foundRecipes.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "fork.knife").font(.system(size: 48)).foregroundColor(.brandGreen.opacity(0.3))
                            Text("No recipes found").font(.recipeRounded(17, weight: .semibold)).foregroundColor(.subtleText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(vm.foundRecipes.enumerated()), id: \.element.id) { index, recipe in
                                    NavigationLink { RecipeDetailView(recipeID: recipe.id) } label: {
                                        SuggestionCard2(recipe: recipe, index: index)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                    }
                } else {
                    ProgressView().tint(.brandGreen)
                        .onAppear { vm = RecipeFinderViewModel(databaseContext: modelContext) }
                }
            }
        }
        .navigationTitle(userIngredientNames.isEmpty ? "All Recipes" : "Based on Your Kitchen")
        .navigationBarTitleDisplayMode(.large)
        .task {
            guard let vm = vm else { return }
            if userIngredientNames.isEmpty { await vm.loadRandomSuggestions(limit: 10) }
            else { await vm.loadIngredientSuggestions(ingredientNames: userIngredientNames, limit: 10) }
        }
        .onChange(of: vm == nil) { _, _ in
            Task {
                guard let vm = vm else { return }
                if userIngredientNames.isEmpty { await vm.loadRandomSuggestions(limit: 10) }
                else { await vm.loadIngredientSuggestions(ingredientNames: userIngredientNames, limit: 10) }
            }
        }
    }
}

// MARK: - Card
private struct SuggestionCard2: View {
    let recipe: RecipeSummaryWithScore
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

            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.recipeRounded(21, weight: .bold))
                    .foregroundColor(.primaryText)
                    .lineLimit(2)
                if recipe.matchScore > 0 {
                    Label("\(recipe.matchScore) matching ingredient\(recipe.matchScore == 1 ? "" : "s")", systemImage: "leaf.fill")
                        .font(.recipeRounded(13, weight: .semibold)).foregroundColor(.brandGreen)
                }
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(.subtleText)
        }
        .padding(18)
        .softCard(cornerRadius: 26)
        .opacity(shown ? 1 : 0)
        .offset(y: shown ? 0 : 14)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(index) * 0.06)) { shown = true }
        }
    }
}
