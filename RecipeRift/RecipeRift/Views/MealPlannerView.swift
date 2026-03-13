import SwiftUI
import SwiftData

struct MealPlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealPlanEntry.date, order: .forward) private var entries: [MealPlanEntry]
    @Query(sort: \GroceryListItem.addedAt, order: .reverse) private var groceryItems: [GroceryListItem]

    var body: some View {
        ZStack {
            Color.pageSurface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    if entries.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.brandGreen.opacity(0.35))
                            Text("Meal planner is empty")
                                .font(.recipeRounded(22, weight: .bold))
                                .foregroundStyle(Color.primaryText)
                            Text("Plan recipes from the detail screen.")
                                .font(.recipeRounded(15, weight: .medium))
                                .foregroundStyle(Color.subtleText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 80)
                    } else {
                        plannerSummary

                        ForEach(groupedEntries, id: \.date) { group in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(group.date.formatted(date: .complete, time: .omitted))
                                        .font(.recipeRounded(18, weight: .bold))
                                        .foregroundStyle(Color.primaryText)
                                    Spacer()
                                    Text("\(group.entries.count) meal\(group.entries.count == 1 ? "" : "s")")
                                        .font(.recipeRounded(13, weight: .bold))
                                        .foregroundStyle(Color.brandGreen)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background(Color.brandGreenLight)
                                        .clipShape(Capsule())
                                }

                                ForEach(group.entries) { entry in
                                    plannerRow(entry)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
        }
        .navigationTitle("Meal Planner")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !entries.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        for entry in entries {
                            modelContext.delete(entry)
                        }
                        try? modelContext.save()
                    }
                }
            }
        }
    }

    private var groupedEntries: [(date: Date, entries: [MealPlanEntry])] {
        let grouped = Dictionary(grouping: entries) { Calendar.current.startOfDay(for: $0.date) }
        return grouped.keys.sorted().map { date in
            (date, (grouped[date] ?? []).sorted { $0.mealSlot < $1.mealSlot })
        }
    }

    private func plannerRow(_ entry: MealPlanEntry) -> some View {
        HStack(spacing: 14) {
            NavigationLink(destination: RecipeDetailView(recipeID: entry.recipeID)) {
                HStack(spacing: 14) {
                    AsyncImage(url: URL(string: entry.recipeImageURL ?? "")) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Color.brandGreenLight
                                .overlay(Image(systemName: "fork.knife").foregroundStyle(Color.brandGreen))
                        }
                    }
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.mealSlot)
                            .font(.recipeRounded(12, weight: .bold))
                            .foregroundStyle(Color.brandGreen)
                        Text(entry.recipeName)
                            .font(.recipeRounded(17, weight: .bold))
                            .foregroundStyle(Color.primaryText)
                            .lineLimit(2)

                        let itemCount = groceryItems.filter { !$0.isChecked && $0.recipeID == entry.recipeID }.count
                        if itemCount > 0 {
                            Text("\(itemCount) grocery item\(itemCount == 1 ? "" : "s") ready")
                                .font(.recipeRounded(12, weight: .medium))
                                .foregroundStyle(Color.subtleText)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            Button {
                modelContext.delete(entry)
                try? modelContext.save()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.subtleText)
                    .frame(width: 34, height: 34)
                    .background(Color.elevatedSurface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .softCard(cornerRadius: 22)
    }

    private var plannerSummary: some View {
        HStack(spacing: 14) {
            summaryCard(
                title: "Planned Meals",
                value: "\(entries.count)",
                icon: "calendar.badge.clock"
            )
            summaryCard(
                title: "Need To Buy",
                value: "\(groceryItems.filter { !$0.isChecked }.count)",
                icon: "cart.badge.plus"
            )
        }
    }

    private func summaryCard(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.brandGreenLight)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.brandGreen)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.recipeRounded(22, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                Text(title)
                    .font(.recipeRounded(13, weight: .medium))
                    .foregroundStyle(Color.subtleText)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .softCard(cornerRadius: 24)
    }
}
