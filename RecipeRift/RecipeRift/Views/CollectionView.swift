//
//  CollectionView.swift
//  RecipeRift
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecentRecipe.viewedAt, order: .reverse) private var recentRecipes: [RecentRecipe]
    @Query(sort: \RecipeCollection.createdAt, order: .forward) private var collections: [RecipeCollection]
    @Query(sort: \CookLog.cookedAt, order: .reverse) private var cookLogs: [CookLog]
    @State private var viewModel: MyRecipesViewModel?
    @State private var headerShown = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageSurface.ignoresSafeArea()

                if let vm = viewModel {
                    let tabBinding = Binding<RecipeFilterTab>(
                        get: { vm.selectedTab },
                        set: { vm.selectedTab = $0; vm.applyFilters() }
                    )
                    let searchBinding = Binding<String>(
                        get: { vm.searchText },
                        set: { vm.searchText = $0; vm.applyFilters() }
                    )

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 26) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bookmark")
                                    .font(.recipeRounded(36, weight: .bold))
                                    .foregroundStyle(Color.primaryText)
                                Text("Keep your saved and cooked recipes close.")
                                    .font(.recipeRounded(16, weight: .medium))
                                    .foregroundStyle(Color.subtleText)
                            }
                            .padding(.top, 12)
                            .opacity(headerShown ? 1 : 0)
                            .offset(y: headerShown ? 0 : -8)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.4)) { headerShown = true }
                            }

                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 19, weight: .medium))
                                    .foregroundStyle(Color.subtleText)

                                TextField("Search saved recipes", text: searchBinding)
                                    .font(.recipeRounded(17, weight: .medium))
                                    .autocorrectionDisabled()

                                if !searchBinding.wrappedValue.isEmpty {
                                    Button { searchBinding.wrappedValue = "" } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(Color.subtleText)
                                    }
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .softField(cornerRadius: 22)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(RecipeFilterTab.allCases, id: \.self) { tab in
                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                                tabBinding.wrappedValue = tab
                                            }
                                        } label: {
                                            Text(tab.rawValue)
                                                .font(.recipeRounded(15, weight: .semibold))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(tabBinding.wrappedValue == tab ? Color.brandGreen : Color.cardSurface)
                                                .foregroundStyle(tabBinding.wrappedValue == tab ? Color.white : Color.primaryText)
                                                .clipShape(Capsule())
                                                .overlay(
                                                    Capsule()
                                                        .stroke(tabBinding.wrappedValue == tab ? Color.clear : Color.borderSoft, lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.vertical, 2)
                            }

                            collectionSummary(vm: vm)

                            if vm.filteredRecipes.isEmpty {
                                VStack(spacing: 14) {
                                    Image(systemName: "bookmark.slash")
                                        .font(.system(size: 48))
                                        .foregroundStyle(Color.brandGreen.opacity(0.32))
                                    Text("No recipes found")
                                        .font(.recipeRounded(20, weight: .bold))
                                        .foregroundStyle(Color.primaryText)
                                    Text("Try another filter or bookmark a few more recipes.")
                                        .font(.recipeRounded(15, weight: .medium))
                                        .foregroundStyle(Color.subtleText)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 46)
                            } else {
                                recentHistorySection
                                collectionFoldersSection
                                savedSections(vm: vm)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 34)
                    }
                } else {
                    ProgressView().tint(.brandGreen)
                        .onAppear { viewModel = MyRecipesViewModel(databaseContext: modelContext) }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            ensureDefaultCollections()
            viewModel?.loadAllRecipes()
            viewModel?.applyFilters()
        }
    }

    @ViewBuilder
    private func collectionSummary(vm: MyRecipesViewModel) -> some View {
        HStack(spacing: 14) {
            StatItem(title: "Saved", value: "\(vm.getTotalBookmarkedCount())", icon: "bookmark.fill", color: .brandGreen)
            StatItem(title: "Cooked", value: "\(vm.getTotalCookedCount())", icon: "flame.fill", color: .brandGold)
        }

        if let favouriteCuisine = vm.getFavoriteCuisine() {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.brandGreen)
                Text("Favorite cuisine: \(favouriteCuisine)")
                    .font(.recipeRounded(14, weight: .semibold))
                    .foregroundStyle(Color.primaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.brandGreenLight)
            .clipShape(Capsule())
        }
    }

    @ViewBuilder
    private func savedSections(vm: MyRecipesViewModel) -> some View {
        let allRecipes = vm.filteredRecipes
        let cookedRecipes = allRecipes.filter(\.hasCooked)
        let recentlyViewed = Array(allRecipes.sorted { ($0.lastViewedAt ?? .distantPast) > ($1.lastViewedAt ?? .distantPast) }.prefix(4))
        let breakfastStyle = Array(allRecipes.dropFirst(4).prefix(4))

        VStack(alignment: .leading, spacing: 26) {
            if !recentlyViewed.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionHeader(title: "Recently Viewed")
                    featuredCollectionStrip(recipes: recentlyViewed)
                }
            }

            if !cookedRecipes.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionHeader(title: "Made It")

                    LazyVStack(spacing: 14) {
                        ForEach(cookedRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipeID: recipe.id)) {
                                RecipeRow(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if !breakfastStyle.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionHeader(title: "Saved Recipes", actionTitle: nil)

                    LazyVStack(spacing: 14) {
                        ForEach(breakfastStyle) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipeID: recipe.id)) {
                                RecipeRow(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } else if cookedRecipes.isEmpty {
                LazyVStack(spacing: 14) {
                    ForEach(allRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipeID: recipe.id)) {
                            RecipeRow(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func featuredCollectionStrip(recipes: [SavedRecipe]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipeID: recipe.id)) {
                        CollectionFeatureTile(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private var recentHistorySection: some View {
        if !recentRecipes.isEmpty || !cookLogs.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                if !recentRecipes.isEmpty {
                    AppSectionHeader(title: "Recently Viewed", actionTitle: nil)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(recentRecipes.prefix(5))) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipeID: recipe.recipeID)) {
                                    CollectionRecentTile(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                if !cookLogs.isEmpty {
                    AppSectionHeader(title: "Cook History", actionTitle: nil)
                    ForEach(Array(cookLogs.prefix(3))) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(log.recipe?.recipeName ?? "Cooked recipe")
                                .font(.recipeRounded(16, weight: .bold))
                                .foregroundStyle(Color.primaryText)
                            Text(log.cookedAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.recipeRounded(13, weight: .medium))
                                .foregroundStyle(Color.brandGreen)
                            if let notes = log.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.recipeRounded(13, weight: .medium))
                                    .foregroundStyle(Color.subtleText)
                                    .lineLimit(2)
                            }
                        }
                        .padding(16)
                        .softField(cornerRadius: 20)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var collectionFoldersSection: some View {
        if !collections.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Collections", actionTitle: nil)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(collections) { collection in
                            NavigationLink(destination: CollectionRecipesView(collection: collection)) {
                                VStack(alignment: .leading, spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(Color.brandGreenLight)
                                            .frame(width: 46, height: 46)
                                        Image(systemName: "square.grid.2x2.fill")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(Color.brandGreen)
                                    }

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(collection.name)
                                            .font(.recipeRounded(16, weight: .bold))
                                            .foregroundStyle(Color.primaryText)
                                            .lineLimit(1)
                                        Text("\((collection.recipes ?? []).count) recipes")
                                            .font(.recipeRounded(13, weight: .medium))
                                            .foregroundStyle(Color.subtleText)
                                    }

                                    HStack(spacing: 6) {
                                        Text("Open")
                                            .font(.recipeRounded(13, weight: .bold))
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .foregroundStyle(Color.brandGreen)
                                }
                                .frame(width: 168, alignment: .leading)
                                .padding(16)
                                .softCard(cornerRadius: 24)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func ensureDefaultCollections() {
        let defaults = ["Breakfast", "High Protein", "Quick Meals", "Favorites"]
        for name in defaults {
            let request = FetchDescriptor<RecipeCollection>(predicate: #Predicate { $0.name == name })
            if (try? modelContext.fetch(request).isEmpty) == true {
                modelContext.insert(RecipeCollection(name: name))
            }
        }
        try? modelContext.save()
    }
}

private struct CollectionFeatureTile: View {
    let recipe: SavedRecipe

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: recipe.pictureURL ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    LinearGradient(
                        colors: [Color.brandGreenLight, Color.softIvory],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.brandGreen.opacity(0.45))
                    )
                }
            }
            .frame(width: 244, height: 170)
            .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.04), Color.black.opacity(0.42)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.recipeName)
                    .font(.recipeRounded(20, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(recipe.cuisineType ?? recipe.categoryType ?? "Saved recipe")
                    .font(.recipeRounded(14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.88))
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .softShadow()
    }
}

private struct CollectionRecentTile: View {
    let recipe: RecentRecipe

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: recipe.pictureURL ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Color.brandGreenLight
                        .overlay(Image(systemName: "fork.knife").foregroundStyle(Color.brandGreen))
                }
            }
            .frame(width: 168, height: 118)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            Text(recipe.recipeName)
                .font(.recipeRounded(16, weight: .bold))
                .foregroundStyle(Color.primaryText)
                .lineLimit(2)
        }
        .frame(width: 168, alignment: .leading)
    }
}
