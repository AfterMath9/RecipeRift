import SwiftUI
import SwiftData

struct GroceryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GroceryListItem.addedAt, order: .reverse) private var items: [GroceryListItem]

    private var activeItems: [GroceryListItem] { items.filter { !$0.isChecked } }
    private var completedItems: [GroceryListItem] { items.filter(\.isChecked) }

    var body: some View {
        ZStack {
            Color.pageSurface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    if activeItems.isEmpty && completedItems.isEmpty {
                        emptyState
                    } else {
                        if !activeItems.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                AppSectionHeader(title: "To Buy", actionTitle: nil)
                                ForEach(activeItems) { item in
                                    groceryRow(item)
                                }
                            }
                        }

                        if !completedItems.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                AppSectionHeader(title: "Checked Off", actionTitle: nil)
                                ForEach(completedItems) { item in
                                    groceryRow(item)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
        }
        .navigationTitle("Grocery List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !items.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        for item in items {
                            modelContext.delete(item)
                        }
                        try? modelContext.save()
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 44))
                .foregroundStyle(Color.brandGreen.opacity(0.35))
            Text("No grocery items yet")
                .font(.recipeRounded(22, weight: .bold))
                .foregroundStyle(Color.primaryText)
            Text("Add missing ingredients from any recipe.")
                .font(.recipeRounded(15, weight: .medium))
                .foregroundStyle(Color.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

    private func groceryRow(_ item: GroceryListItem) -> some View {
        HStack(spacing: 14) {
            Button {
                item.isChecked.toggle()
                try? modelContext.save()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(item.isChecked ? Color.brandGreen : Color.elevatedSurface)
                        .frame(width: 32, height: 32)
                    if item.isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.ingredientName)
                    .font(.recipeRounded(16, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                    .strikethrough(item.isChecked)

                if let quantity = item.quantity, !quantity.isEmpty {
                    Text(quantity)
                        .font(.recipeRounded(13, weight: .medium))
                        .foregroundStyle(Color.subtleText)
                }

                if let recipeName = item.recipeName {
                    Text(recipeName)
                        .font(.recipeRounded(12, weight: .medium))
                        .foregroundStyle(Color.brandGreen)
                }
            }

            Spacer()

            Button {
                modelContext.delete(item)
                try? modelContext.save()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.subtleText)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .softCard(cornerRadius: 22)
    }
}
