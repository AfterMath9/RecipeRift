//
//  ExploreView.swift
//  RecipeRift
//

import SwiftUI

struct ExploreView: View {
    @State private var vm = ExploreViewModel()
    @State private var headerShown = false
    private let browseLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map(String.init)

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageSurface.ignoresSafeArea()

                if vm.isLoadingCategories || vm.isLoadingAreas {
                    VStack(spacing: 14) {
                        ProgressView().tint(.brandGreen).scaleEffect(1.3)
                        Text("Loading…")
                            .font(.recipeRounded(15, weight: .medium))
                            .foregroundColor(.subtleText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Explore")
                                    .font(.recipeRounded(36, weight: .bold))
                                    .foregroundStyle(Color.primaryText)
                                Text("Discover your next favourite dish")
                                    .font(.recipeRounded(16, weight: .medium))
                                    .foregroundStyle(Color.subtleText)
                            }
                            .padding(.top, 12)
                            .opacity(headerShown ? 1 : 0)
                            .offset(y: headerShown ? 0 : -8)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.4)) { headerShown = true }
                            }

                            if !vm.latestMeals.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    AppSectionHeader(title: "Recommendation")

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(Array(vm.latestMeals.enumerated()), id: \.element.id) { index, meal in
                                                NavigationLink { RecipeDetailView(recipeID: meal.id) } label: {
                                                    LatestMealCard(meal: meal, index: index)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }

                            if !vm.categories.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    AppSectionHeader(title: "Categories")

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 14) {
                                            ForEach(vm.categories) { category in
                                                NavigationLink {
                                                    RecipeListView(
                                                        title: category.name,
                                                        vm: vm,
                                                        loadAction: { await vm.showRecipesFor(category: category.name) }
                                                    )
                                                } label: {
                                                    CategoryCard(category: category)
                                                }
                                                .buttonStyle(PressScaleStyle())
                                            }
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }

                            if !vm.areas.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text("Browse by Cuisine")
                                            .font(.recipeRounded(18, weight: .bold))
                                            .foregroundStyle(Color.primaryText)
                                        Spacer()
                                        NavigationLink {
                                            AllCuisinesView(vm: vm)
                                        } label: {
                                            Text("See all")
                                                .font(.recipeRounded(15, weight: .semibold))
                                                .foregroundStyle(Color.brandGreen)
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 14) {
                                            ForEach(Array(vm.areas.prefix(8))) { area in
                                                NavigationLink {
                                                    RecipeListView(
                                                        title: area.name,
                                                        vm: vm,
                                                        loadAction: { await vm.showRecipesFor(area: area.name) }
                                                    )
                                                } label: {
                                                    AreaCard(area: area)
                                                }
                                                .buttonStyle(PressScaleStyle())
                                            }
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 14) {
                                AppSectionHeader(title: "Browse A-Z", actionTitle: nil)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(browseLetters, id: \.self) { letter in
                                            NavigationLink {
                                                RecipeListView(
                                                    title: letter,
                                                    vm: vm,
                                                    loadAction: { await vm.showRecipesFor(firstLetter: letter) }
                                                )
                                            } label: {
                                                Text(letter)
                                                    .font(.recipeRounded(16, weight: .bold))
                                                    .foregroundStyle(Color.primaryText)
                                                    .frame(width: 44, height: 44)
                                                    .background(Color.cardSurface)
                                                    .clipShape(Circle())
                                                    .overlay(Circle().stroke(Color.borderSoft, lineWidth: 1))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 34)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            async let categories: () = vm.categories.isEmpty ? vm.loadCategories() : ()
            async let areas: () = vm.areas.isEmpty ? vm.loadAreas() : ()
            async let latest: () = vm.latestMeals.isEmpty ? vm.loadLatestMeals() : ()
            _ = await (categories, areas, latest)
        }
    }
}

private struct AllCuisinesView: View {
    let vm: ExploreViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 14
            ) {
                ForEach(vm.areas) { area in
                    NavigationLink {
                        RecipeListView(
                            title: area.name,
                            vm: vm,
                            loadAction: { await vm.showRecipesFor(area: area.name) }
                        )
                    } label: {
                        AreaCard(area: area)
                    }
                    .buttonStyle(PressScaleStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .background(Color.pageSurface.ignoresSafeArea())
        .navigationTitle("All Cuisines")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LatestMealCard: View {
    let meal: RecipeDetails
    let index: Int
    @State private var shown = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: meal.pictureURL ?? "")) { phase in
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
            .frame(width: 210, height: 210)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.recipeName)
                    .font(.recipeRounded(18, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                    .lineLimit(2)
                    .frame(height: 46, alignment: .topLeading)

                Text(meal.cuisineType ?? meal.categoryType ?? "Featured recipe")
                    .font(.recipeRounded(14, weight: .medium))
                    .foregroundStyle(Color.subtleText)
                    .lineLimit(1)
            }
        }
        .frame(width: 210, alignment: .leading)
        .opacity(shown ? 1 : 0)
        .offset(y: shown ? 0 : 16)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78).delay(Double(index) * 0.07)) { shown = true }
        }
    }
}
