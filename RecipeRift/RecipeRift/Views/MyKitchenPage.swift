
//
//  MyKitchenPage.swift
//  RecipeRift
//

import SwiftUI
import SwiftData

struct MyKitchenPage: View {
    @State private var showingAddSheet = false
    @State private var ingredientToEdit: KitchenIngredient? = nil
    let kvm: MyKitchenViewModel

    var body: some View {
        let searchBinding = Binding<String>(
            get: { kvm.searchText }, set: { kvm.searchText = $0 }
        )
        let categoryBinding = Binding<String>(
            get: { kvm.selectedCategory }, set: { kvm.selectedCategory = $0 }
        )

        ZStack {
            Color.pageSurface.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Category Filter ──────────────────────────────────────
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(["All", "Protein", "Vegetable", "Grain", "Dairy", "Pantry", "Spice"], id: \.self) { cat in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { categoryBinding.wrappedValue = cat }
                            } label: {
                                Text(cat)
                                    .font(.caption).fontWeight(.semibold)
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(categoryBinding.wrappedValue == cat ? Color.brandGreen : Color.chipSurface)
                                    .foregroundColor(categoryBinding.wrappedValue == cat ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20).padding(.vertical, 12)
                }

                Divider().padding(.horizontal, 20)

                // ── Ingredient List ──────────────────────────────────────
                let ingredients = kvm.getFilteredIngredients()
                if ingredients.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "cart.badge.plus").font(.system(size: 44)).foregroundColor(.brandGreen.opacity(0.3))
                        Text("No ingredients yet.").font(.headline)
                        Text("Tap + to add some.").font(.subheadline).foregroundColor(.subtleText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(ingredients) { ingredient in
                                KitchenIngredientRow(
                                    ingredient: ingredient, kvm: kvm,
                                    onEdit: { ingredientToEdit = ingredient }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, kvm.getSelectedIngredients().isEmpty ? 20 : 100)
                        .padding(.top, 12)
                    }
                }
            }
        }
        .searchable(text: searchBinding, prompt: "Search pantry ingredients")
        .navigationTitle("My Kitchen")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddSheet = true } label: {
                    ZStack {
                        Circle().fill(Color.brandGreen).frame(width: 32, height: 32)
                        Image(systemName: "plus").foregroundColor(.white).font(.system(size: 13, weight: .bold))
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !kvm.getSelectedIngredients().isEmpty {
                NavigationLink {
                    RecipeSearchView(selectedIngredients: kvm.getSelectedIngredients())
                } label: {
                    Label("Find Recipes (\(kvm.getSelectedIngredients().count))", systemImage: "sparkles")
                        .bold()
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color.brandGreen).foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20).padding(.bottom, 8)
                }
                .buttonStyle(.plain)
                .background(.ultraThinMaterial)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showingAddSheet) { AddIngredientSheet(viewModel: kvm) }
        .sheet(item: $ingredientToEdit) { ingredient in EditIngredientSheet(viewModel: kvm, ingredient: ingredient) }
    }
}

// MARK: - Ingredient Row
private struct KitchenIngredientRow: View {
    let ingredient: KitchenIngredient
    let kvm: MyKitchenViewModel
    let onEdit: () -> Void
    @State private var shown = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { kvm.toggleSelection(ingredient) }
            } label: {
                ZStack {
                    Circle()
                        .fill(ingredient.isSelected ? Color.brandGreen : Color.chipSurface)
                        .frame(width: 30, height: 30)
                    if ingredient.isSelected {
                        Image(systemName: "checkmark").font(.caption.bold()).foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(ingredient.name).font(.headline).foregroundColor(.primary)
                HStack(spacing: 6) {
                    Text(ingredient.category)
                        .font(.caption).fontWeight(.semibold)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.brandGreenLight).foregroundColor(.brandGreen)
                        .clipShape(Capsule())
                    if let qty = ingredient.howMuch {
                        Text(qty).font(.caption).foregroundColor(.subtleText)
                    }
                }
                if let expiry = ingredient.expiresOn {
                    Text("Expires: \(expiry.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(ingredient.isExpiringSoon ? .red : .subtleText)
                }
            }

            Spacer()

            Button(action: onEdit) {
                ZStack {
                    Circle().fill(Color.chipSurface).frame(width: 30, height: 30)
                    Image(systemName: "pencil").font(.caption).foregroundColor(.subtleText)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .cardShadow(radius: 4, y: 2)
        .opacity(shown ? 1 : 0)
        .offset(x: shown ? 0 : -10)
        .onAppear { withAnimation(.easeOut(duration: 0.3)) { shown = true } }
    }
}
