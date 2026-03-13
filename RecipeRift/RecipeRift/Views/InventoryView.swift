//
//  InventoryView.swift
//  RecipeRift
//

import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    @AppStorage("proPlan") private var proPlanRawValue = ProPlan.free.rawValue
    @Query(sort: \RecentRecipe.viewedAt, order: .reverse) private var recentRecipes: [RecentRecipe]
    @Query(sort: \MealPlanEntry.date, order: .forward) private var mealPlans: [MealPlanEntry]
    @State private var kitchenVM: MyKitchenViewModel?
    @State private var recipeVM: RecipeFinderViewModel?
    @State private var showingAddSheet = false
    @State private var showingGroceryList = false
    @State private var showingMealPlanner = false
    @State private var showingAccount = false
    @State private var showingPaywall = false
    @State private var lockedFeature: PremiumFeature?
    @State private var recipeSearchText = ""
    @State private var searchTask: Task<Void, Never>? = nil
    @State private var headerShown = false

    private var isPro: Bool { PremiumAccess.plan(from: proPlanRawValue).isPro }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageSurface.ignoresSafeArea()

                if let kvm = kitchenVM, let rvm = recipeVM {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {
                            homeHeader
                                .padding(.top, 12)

                            searchBar

                            kitchenSection(kvm: kvm)

                            pantryAlertsSection(kvm: kvm)

                            recentViewsSection

                            plannerPreviewSection

                            contentSection(kvm: kvm, rvm: rvm)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 34)
                    }
                    .sheet(isPresented: $showingAddSheet) { AddIngredientSheet(viewModel: kvm) }
                    .sheet(isPresented: $showingGroceryList) { NavigationStack { GroceryListView() } }
                    .sheet(isPresented: $showingMealPlanner) { NavigationStack { MealPlannerView() } }
                    .sheet(isPresented: $showingAccount) { AccountView() }
                    .sheet(isPresented: $showingPaywall) {
                        PaywallView(focusFeature: lockedFeature)
                    }
                    .onAppear {
                        if rvm.foundRecipes.isEmpty && !rvm.isSearching {
                            let names = kvm.allIngredients.map { $0.name }
                            Task {
                                if names.isEmpty { await rvm.loadRandomSuggestions(limit: 3) }
                                else { await rvm.loadIngredientSuggestions(ingredientNames: names, limit: 3) }
                            }
                        }
                    }
                } else {
                    VStack(spacing: 14) {
                        ProgressView().tint(.brandGreen).scaleEffect(1.3)
                        Text("Loading your kitchen…")
                            .font(.recipeRounded(15, weight: .medium))
                            .foregroundColor(.subtleText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        kitchenVM = MyKitchenViewModel(databaseContext: modelContext)
                        recipeVM  = RecipeFinderViewModel(databaseContext: modelContext)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var homeHeader: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Hello, Chef")
                    .font(.recipeRounded(18, weight: .medium))
                    .foregroundStyle(Color.subtleText)

                Text("What would you like\nto cook today?")
                    .font(.recipeRounded(36, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                    .lineSpacing(1)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    if isPro {
                        showingMealPlanner = true
                    } else {
                        lockedFeature = .mealPlanner
                        showingPaywall = true
                    }
                } label: {
                    Circle()
                        .fill(Color.cardSurface)
                        .frame(width: 48, height: 48)
                        .overlay(Image(systemName: "calendar").foregroundStyle(Color.primaryText))
                        .overlay(Circle().stroke(Color.borderSoft, lineWidth: 1))
                }
                .buttonStyle(.plain)

                Button { showingGroceryList = true } label: {
                    Circle()
                        .fill(Color.cardSurface)
                        .frame(width: 48, height: 48)
                        .overlay(Image(systemName: "cart").foregroundStyle(Color.primaryText))
                        .overlay(Circle().stroke(Color.borderSoft, lineWidth: 1))
                }
                .buttonStyle(.plain)

                Button { showingAccount = true } label: {
                    ZStack {
                        Circle()
                            .fill(Color.brandGreenLight)
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.brandGreen, Color.white)
                            .padding(6)
                    }
                    .frame(width: 56, height: 56)
                }
                .buttonStyle(.plain)
            }
        }
        .opacity(headerShown ? 1 : 0)
        .offset(y: headerShown ? 0 : -12)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { headerShown = true }
        }
    }

    @ViewBuilder
    private func pantryAlertsSection(kvm: MyKitchenViewModel) -> some View {
        let expiringIngredients = kvm.getIngredientsThatWillExpireSoon()

        if isPro, !expiringIngredients.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Smart Pantry Alerts", actionTitle: nil)

                VStack(alignment: .leading, spacing: 10) {
                    Text("\(expiringIngredients.count) ingredient\(expiringIngredients.count == 1 ? "" : "s") expiring soon")
                        .font(.recipeRounded(17, weight: .bold))
                        .foregroundStyle(Color.primaryText)

                    Text(expiringIngredients.prefix(4).map(\.name).joined(separator: ", "))
                        .font(.recipeRounded(14, weight: .medium))
                        .foregroundStyle(Color.subtleText)

                    NavigationLink {
                        AllSuggestionsView(userIngredientNames: expiringIngredients.map { $0.name })
                    } label: {
                        Text("Use Them Now")
                            .font(.recipeRounded(15, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.brandGreen)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(18)
                .softCard()
            }
        } else if !isPro {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Smart Pantry Alerts", actionTitle: "Pro")

                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.brandGreenLight)
                            .frame(width: 56, height: 56)
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.brandGreen)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Unlock expiry alerts")
                            .font(.recipeRounded(17, weight: .bold))
                            .foregroundStyle(Color.primaryText)
                        Text("Get use-it-now nudges before ingredients go to waste.")
                            .font(.recipeRounded(14, weight: .medium))
                            .foregroundStyle(Color.subtleText)
                    }

                    Spacer()
                }
                .padding(18)
                .softCard()
                .onTapGesture {
                    lockedFeature = .pantryAlerts
                    showingPaywall = true
                }
            }
        }
    }

    @ViewBuilder
    private var recentViewsSection: some View {
        if !recentRecipes.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Recently Viewed", actionTitle: nil)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(Array(recentRecipes.prefix(6))) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipeID: recipe.recipeID)
                            } label: {
                                RecentRecipeTile(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    @ViewBuilder
    private var plannerPreviewSection: some View {
        if !mealPlans.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Meal Planner")
                        .font(.recipeRounded(18, weight: .bold))
                        .foregroundStyle(Color.primaryText)
                    Spacer()
                    Button {
                        showingMealPlanner = true
                    } label: {
                        Text("Open")
                            .font(.recipeRounded(15, weight: .semibold))
                            .foregroundStyle(Color.brandGreen)
                    }
                    .buttonStyle(.plain)
                }

                ForEach(Array(mealPlans.prefix(3))) { plan in
                    HStack(spacing: 12) {
                        Text(plan.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.recipeRounded(13, weight: .bold))
                            .foregroundStyle(Color.brandGreen)
                            .frame(width: 72, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(plan.recipeName)
                                .font(.recipeRounded(15, weight: .bold))
                                .foregroundStyle(Color.primaryText)
                                .lineLimit(1)
                            Text(plan.mealSlot)
                                .font(.recipeRounded(13, weight: .medium))
                                .foregroundStyle(Color.subtleText)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .softField(cornerRadius: 18)
                }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(Color.subtleText)

            TextField("Search any recipes", text: $recipeSearchText)
                .font(.recipeRounded(17, weight: .medium))
                .autocorrectionDisabled()
                .onChange(of: recipeSearchText) { _, newValue in
                    searchTask?.cancel()
                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 400_000_000)
                        guard !Task.isCancelled else { return }
                        let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                        if trimmed.isEmpty {
                            guard let kvm = kitchenVM, let rvm = recipeVM else { return }
                            let names = kvm.allIngredients.map { $0.name }
                            if names.isEmpty {
                                await rvm.loadRandomSuggestions(limit: 3)
                            } else {
                                await rvm.loadIngredientSuggestions(ingredientNames: names, limit: 3)
                            }
                        } else {
                            await recipeVM?.searchForRecipesByName(query: trimmed)
                        }
                    }
                }

            if !recipeSearchText.isEmpty {
                Button { recipeSearchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.subtleText)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .softField(cornerRadius: 22)
    }

    @ViewBuilder
    private func kitchenSection(kvm: MyKitchenViewModel) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                AppSectionHeader(title: "My Kitchen", actionTitle: nil)

                Spacer()

                NavigationLink { MyKitchenPage(kvm: kvm) } label: {
                    Text("Manage")
                        .font(.recipeRounded(15, weight: .semibold))
                        .foregroundStyle(Color.brandGreen)
                }
            }

            if kvm.allIngredients.isEmpty {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.brandGreenLight)
                            .frame(width: 58, height: 58)
                        Image(systemName: "refrigerator.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.brandGreen)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your kitchen is empty")
                            .font(.recipeRounded(18, weight: .bold))
                            .foregroundStyle(Color.primaryText)
                        Text("Use the add button in the navbar to save ingredients.")
                            .font(.recipeRounded(14, weight: .medium))
                            .foregroundStyle(Color.subtleText)
                    }

                    Spacer()
                }
                .padding(18)
                .softCard()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(kvm.allIngredients.prefix(10)) { ingredient in
                            Button { kvm.toggleSelection(ingredient) } label: {
                                VStack(spacing: 10) {
                                    Text(ingredientEmoji(for: ingredient.name))
                                        .font(.system(size: 26))
                                    Text(ingredient.name)
                                        .font(.recipeRounded(14, weight: .semibold))
                                        .foregroundStyle(ingredient.isSelected ? Color.white : Color.primaryText)
                                        .lineLimit(1)
                                }
                                .frame(width: 96, height: 92)
                                .background(ingredient.isSelected ? Color.brandGreen : Color.cardSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(ingredient.isSelected ? Color.clear : Color.borderSoft, lineWidth: 1)
                                )
                                .softShadow()
                            }
                            .buttonStyle(.plain)
                        }

                        if kvm.allIngredients.count > 10 {
                            NavigationLink { MyKitchenPage(kvm: kvm) } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(Color.brandGreen)
                                    Text("+\(kvm.allIngredients.count - 10) more")
                                        .font(.recipeRounded(14, weight: .semibold))
                                        .foregroundStyle(Color.primaryText)
                                }
                                .frame(width: 96, height: 92)
                                .softCard(cornerRadius: 22)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }

                if !kvm.getSelectedIngredients().isEmpty {
                    NavigationLink {
                        RecipeSearchView(selectedIngredients: kvm.getSelectedIngredients())
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 15, weight: .bold))
                            Text("Find recipes using \(kvm.getSelectedIngredients().count) ingredient\(kvm.getSelectedIngredients().count == 1 ? "" : "s")")
                                .font(.recipeRounded(16, weight: .bold))
                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(Color.brandGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .softShadow()
                    }
                    .buttonStyle(.plain)
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
                }
            }
        }
    }

    @ViewBuilder
    private func contentSection(kvm: MyKitchenViewModel, rvm: RecipeFinderViewModel) -> some View {
        if rvm.isSearching {
            VStack(spacing: 10) {
                ProgressView().tint(.brandGreen)
                Text(recipeSearchText.isEmpty ? "Loading suggestions…" : "Searching…")
                    .font(.recipeRounded(15, weight: .medium))
                    .foregroundStyle(Color.subtleText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        } else if rvm.foundRecipes.isEmpty && !recipeSearchText.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 42))
                    .foregroundStyle(Color.brandGreen.opacity(0.4))
                Text("No results for \"\(recipeSearchText)\"")
                    .font(.recipeRounded(17, weight: .semibold))
                    .foregroundStyle(Color.subtleText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
        } else if !rvm.foundRecipes.isEmpty {
            let recommendations = Array(rvm.foundRecipes.prefix(3))
            let secondaryRecipes = Array(rvm.foundRecipes.dropFirst(3))

            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(recipeSearchText.isEmpty ? "Recommendation" : "Results")
                            .font(.recipeRounded(18, weight: .bold))
                            .foregroundStyle(Color.primaryText)
                        Spacer()
                        if recipeSearchText.isEmpty {
                            NavigationLink {
                                AllSuggestionsView(userIngredientNames: kvm.allIngredients.map { $0.name })
                            } label: {
                                Text("See all")
                                    .font(.recipeRounded(15, weight: .semibold))
                                    .foregroundStyle(Color.brandGreen)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(Array(recommendations.enumerated()), id: \.element.id) { index, recipe in
                                NavigationLink { RecipeDetailView(recipeID: recipe.id) } label: {
                                    RecommendationCard(recipe: recipe, index: index)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                if !secondaryRecipes.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        AppSectionHeader(
                            title: recipeSearchText.isEmpty ? "Recipes Of The Week" : "More Recipes",
                            actionTitle: nil
                        )

                        LazyVStack(spacing: 16) {
                            ForEach(Array(secondaryRecipes.enumerated()), id: \.element.id) { index, recipe in
                                NavigationLink { RecipeDetailView(recipeID: recipe.id) } label: {
                                    WeeklyRecipeCard(recipe: recipe, index: index)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }

    private func ingredientEmoji(for ingredient: String) -> String {
        let lowercased = ingredient.lowercased()
        if lowercased.contains("egg") { return "🥚" }
        if lowercased.contains("milk") || lowercased.contains("cream") { return "🥛" }
        if lowercased.contains("cheese") { return "🧀" }
        if lowercased.contains("tomato") { return "🍅" }
        if lowercased.contains("onion") { return "🧅" }
        if lowercased.contains("garlic") { return "🧄" }
        if lowercased.contains("potato") { return "🥔" }
        if lowercased.contains("chicken") { return "🍗" }
        if lowercased.contains("beef") { return "🥩" }
        if lowercased.contains("fish") || lowercased.contains("salmon") { return "🐟" }
        if lowercased.contains("rice") { return "🍚" }
        if lowercased.contains("pasta") { return "🍝" }
        if lowercased.contains("apple") { return "🍎" }
        if lowercased.contains("banana") { return "🍌" }
        if lowercased.contains("lemon") { return "🍋" }
        if lowercased.contains("bread") { return "🍞" }
        return "🥘"
    }
}

private struct RecentRecipeTile: View {
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
            .frame(width: 154, height: 118)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            Text(recipe.recipeName)
                .font(.recipeRounded(16, weight: .bold))
                .foregroundStyle(Color.primaryText)
                .lineLimit(2)

            Text(recipe.cuisineType ?? "Recent recipe")
                .font(.recipeRounded(13, weight: .medium))
                .foregroundStyle(Color.subtleText)
        }
        .frame(width: 154, alignment: .leading)
    }
}

private struct RecommendationCard: View {
    let recipe: RecipeSummaryWithScore
    let index: Int
    @State private var shown = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: recipe.pictureURL ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.brandGreenLight.overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.brandGreen.opacity(0.45))
                    )
                }
            }
            .frame(width: 208, height: 188)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.recipeRounded(18, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                    .lineLimit(2)
                    .frame(height: 46, alignment: .topLeading)

                Text(recipe.matchScore > 0 ? "\(recipe.matchScore) matching ingredients" : "Fresh recipe pick")
                    .font(.recipeRounded(14, weight: .medium))
                    .foregroundStyle(Color.subtleText)
                    .lineLimit(1)
            }
        }
        .frame(width: 208, alignment: .leading)
        .opacity(shown ? 1 : 0)
        .offset(y: shown ? 0 : 14)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(index) * 0.07)) { shown = true }
        }
    }
}

private struct WeeklyRecipeCard: View {
    let recipe: RecipeSummaryWithScore
    let index: Int
    @State private var shown = false

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
            .frame(height: 210)
            .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.02), Color.black.opacity(0.42)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.recipeRounded(24, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(recipe.matchScore > 0 ? "\(recipe.matchScore) ingredients already in your kitchen" : "Chef-curated for you")
                    .font(.recipeRounded(14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(2)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .softShadow()
        .opacity(shown ? 1 : 0)
        .offset(y: shown ? 0 : 14)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(index) * 0.07)) { shown = true }
        }
    }
}
