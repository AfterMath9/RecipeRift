
//
//  RecipeSearchView.swift
//  RecipeRift
//

import SwiftUI
import SwiftData

struct RecipeSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: RecipeFinderViewModel?
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>? = nil

    var selectedIngredients: [KitchenIngredient]

    var body: some View {
        ZStack {
            Color.pageSurface.ignoresSafeArea()

            if let vm = viewModel {
                VStack(spacing: 0) {

                    // ── Search Bar ──────────────────────────────────────
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundColor(.subtleText)
                        TextField("Search by recipe name", text: $searchText)
                            .autocorrectionDisabled()
                            .onChange(of: searchText) { _, newValue in
                                searchTask?.cancel()
                                searchTask = Task {
                                    try? await Task.sleep(nanoseconds: 400_000_000)
                                    guard !Task.isCancelled else { return }
                                    let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                                    if trimmed.isEmpty { searchByIngredients(vm: vm) }
                                    else { await vm.searchForRecipesByName(query: trimmed) }
                                }
                            }
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.subtleText)
                            }
                        }
                    }
                    .padding(13)
                    .background(Color.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .cardShadow(radius: 4, y: 2)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)

                    // ── Ingredient Chips ────────────────────────────────
                    if !selectedIngredients.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selectedIngredients) { ingredient in
                                    HStack(spacing: 4) {
                                        Image(systemName: "leaf.fill").font(.caption2)
                                        Text(ingredient.name).font(.caption).fontWeight(.semibold)
                                    }
                                    .padding(.horizontal, 12).padding(.vertical, 7)
                                    .background(Color.brandGreenLight)
                                    .foregroundColor(.brandGreen)
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 10)
                    }

                    Divider().padding(.horizontal, 20)

                    // ── Content ─────────────────────────────────────────
                    if vm.isSearching {
                        Spacer()
                        VStack(spacing: 12) {
                            ProgressView().tint(.brandGreen).scaleEffect(1.3)
                            Text("Searching recipes…").font(.subheadline).foregroundColor(.subtleText)
                        }
                        Spacer()
                    } else if let err = vm.errorMessage {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "wifi.exclamationmark").font(.system(size: 44)).foregroundColor(.orange)
                            Text(err).multilineTextAlignment(.center).foregroundColor(.subtleText)
                            Button("Try Again") {
                                if searchText.trimmingCharacters(in: .whitespaces).isEmpty { searchByIngredients(vm: vm) }
                                else { searchTask = Task { await vm.searchForRecipesByName(query: searchText) } }
                            }
                            .padding(.horizontal, 24).padding(.vertical, 10)
                            .background(Color.brandGreen).foregroundColor(.white).clipShape(Capsule())
                        }
                        .padding(40)
                        Spacer()
                    } else if vm.foundRecipes.isEmpty {
                        Spacer()
                        VStack(spacing: 14) {
                            Image(systemName: "magnifyingglass").font(.system(size: 48)).foregroundColor(.brandGreen.opacity(0.25))
                            Text("No recipes found").font(.headline)
                            Text("Try different ingredients or search by name.")
                                .font(.subheadline).foregroundColor(.subtleText).multilineTextAlignment(.center)
                        }
                        .padding(40)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(vm.foundRecipes.enumerated()), id: \.element.id) { index, recipe in
                                    NavigationLink { RecipeDetailView(recipeID: recipe.id) } label: {
                                        SearchResultCard(recipe: recipe, isSaved: vm.isAlreadySaved(recipeID: recipe.id), index: index)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                    }
                }
                .navigationTitle(selectedIngredients.isEmpty ? "All Recipes" : "Recipes")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button("Best Match") { vm.sortRecipesByBestMatch() }
                            Button("Name (A-Z)") { vm.sortRecipesByName() }
                        } label: {
                            ZStack {
                                Circle().fill(Color.chipSurface).frame(width: 32, height: 32)
                                Image(systemName: "arrow.up.arrow.down").font(.caption.bold())
                            }
                        }
                    }
                }
                .onAppear {
                    if vm.foundRecipes.isEmpty && !vm.isSearching { searchByIngredients(vm: vm) }
                }
            } else {
                ProgressView().tint(.brandGreen)
                    .onAppear { viewModel = RecipeFinderViewModel(databaseContext: modelContext) }
            }
        }
    }

    private func searchByIngredients(vm: RecipeFinderViewModel) {
        let names = selectedIngredients.map { $0.name }
        if names.isEmpty { Task { await vm.loadRandomSuggestions() } }
        else { Task { await vm.searchForRecipes(withIngredients: names) } }
    }
}

// MARK: - Search Result Card
private struct SearchResultCard: View {
    let recipe: RecipeSummaryWithScore
    let isSaved: Bool
    let index: Int
    @State private var shown = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            AsyncImage(url: URL(string: recipe.pictureURL ?? "")) { phase in
                if let img = phase.image { img.resizable().aspectRatio(contentMode: .fill) }
                else { Color.brandGreenLight.overlay(Image(systemName: "photo").foregroundColor(.brandGreen.opacity(0.4))) }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 5) {
                Text(recipe.name).font(.headline).foregroundColor(.primary).lineLimit(2)
                if recipe.matchScore > 0 {
                    Label("Uses \(recipe.matchScore) ingredient\(recipe.matchScore == 1 ? "" : "s")", systemImage: "leaf.fill")
                        .font(.caption).foregroundColor(.brandGreen)
                }
            }
            Spacer()
            VStack(spacing: 6) {
                if isSaved { Image(systemName: "bookmark.fill").foregroundColor(.brandGreen) }
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.subtleText)
            }
        }
        .padding(14)
        .background(Color.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .cardShadow(radius: 6, y: 3)
        .opacity(shown ? 1 : 0)
        .offset(y: shown ? 0 : 14)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(index) * 0.055)) { shown = true }
        }
    }
}
