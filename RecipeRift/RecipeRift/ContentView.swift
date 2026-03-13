
//
//  ContentView.swift
//  RecipeRift
//

import SwiftUI
import SwiftData

// MARK: - Root Router
struct ContentView: View {
    var body: some View {
        if #available(iOS 26, *) {
            iOS26ContentView()
        } else {
            LegacyContentView()
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: iOS 26 — Native liquid glass pill + native circle button
//
// Tab(role: .search) tells iOS 26 to render this tab as a SEPARATE circle
// button to the RIGHT of the pill — exactly like the Photos search button.
// We intercept the selection change, show a sheet, and snap back to the
// previous tab so the button never actually "navigates" anywhere.
// ─────────────────────────────────────────────────────────────────────────────
@available(iOS 26, *)
private struct iOS26ContentView: View {
    @State private var selectedTab  = 0
    @State private var previousTab  = 0
    @State private var showAddSheet = false
    @Environment(\.modelContext) private var modelContext

    // The "add" tab's tag — any Int not used by real tabs
    private let addTabTag = 99

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("My Kitchen", systemImage: "refrigerator", value: 0) {
                InventoryView()
            }
            Tab("Explore", systemImage: "safari", value: 1) {
                ExploreView()
            }
            Tab("Collection", systemImage: "book.fill", value: 2) {
                CollectionView()
            }
            // role: .search = renders as a standalone circle BESIDE the pill
            // We repurpose it as our Add button.
            Tab("Add", systemImage: "plus", value: addTabTag, role: .search) {
                Color.clear // never actually shown
            }
        }
        .tint(.brandGreen)
        // When the user taps the circle (+), intercept and show sheet instead
        .onChange(of: selectedTab) { old, new in
            if new == addTabTag {
                showAddSheet  = true
                selectedTab   = old   // snap back — keep pill on previous tab
            } else {
                previousTab = new
            }
        }
        .sheet(isPresented: $showAddSheet, onDismiss: {
            // Make sure we're never stuck on the ghost tab after dismiss
            if selectedTab == addTabTag { selectedTab = previousTab }
        }) {
            AddIngredientSheet(
                viewModel: MyKitchenViewModel(databaseContext: modelContext)
            )
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: iOS 17/18 — Custom frosted-glass pill + circle (same visual design)
// ─────────────────────────────────────────────────────────────────────────────
private struct LegacyContentView: View {
    @State private var selectedTab  = 0
    @State private var showAddSheet = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack(alignment: .bottom) {

            // Pages
            Group {
                switch selectedTab {
                case 0:  InventoryView()
                case 1:  ExploreView()
                default: CollectionView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 96) }

            // Pill + circle on the SAME row
            HStack(alignment: .center, spacing: 14) {

                // Frosted glass pill
                HStack(spacing: 0) {
                    LegacyTab(icon: "refrigerator", label: "My Kitchen",  index: 0, selected: $selectedTab)
                    LegacyTab(icon: "safari",        label: "Explore",     index: 1, selected: $selectedTab)
                    LegacyTab(icon: "book.fill",     label: "Collection",  index: 2, selected: $selectedTab)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(Capsule().strokeBorder(.white.opacity(0.14), lineWidth: 1))
                }
                .shadow(color: .black.opacity(0.28), radius: 20, x: 0, y: 8)

                // Standalone circle — matches the pill material
                Button { showAddSheet = true } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(Circle().strokeBorder(.white.opacity(0.14), lineWidth: 1))
                            .shadow(color: .black.opacity(0.26), radius: 16, x: 0, y: 6)
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.brandGreen)
                    }
                    .frame(width: 58, height: 58)
                }
                .buttonStyle(SpringButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showAddSheet) {
            AddIngredientSheet(
                viewModel: MyKitchenViewModel(databaseContext: modelContext)
            )
        }
    }
}

// MARK: - Legacy tab item
private struct LegacyTab: View {
    let icon:     String
    let label:    String
    let index:    Int
    @Binding var selected: Int
    private var isSelected: Bool { selected == index }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selected = index }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? Color.brandGreen : Color.primary.opacity(0.45))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isSelected)
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? Color.brandGreen : Color.primary.opacity(0.45))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.brandGreen.opacity(0.13))
                        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview { ContentView().modelContainer(for: [KitchenIngredient.self, SavedRecipe.self]) }
