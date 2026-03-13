import SwiftUI

struct AddMealPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var selectedSlot: MealPlannerSlot = .dinner
    @State private var includeMissingIngredients = true

    let onSave: (Date, MealPlannerSlot, Bool) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageSurface.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 18) {
                    DatePicker("Plan date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding(16)
                        .softCard(cornerRadius: 24)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Meal slot")
                            .font(.recipeRounded(16, weight: .bold))
                            .foregroundStyle(Color.primaryText)

                        HStack(spacing: 10) {
                            ForEach(MealPlannerSlot.allCases, id: \.self) { slot in
                                Button {
                                    selectedSlot = slot
                                } label: {
                                    Text(slot.rawValue)
                                        .font(.recipeRounded(14, weight: .bold))
                                        .foregroundStyle(selectedSlot == slot ? Color.white : Color.primaryText)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(selectedSlot == slot ? Color.brandGreen : Color.elevatedSurface)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                    .softCard(cornerRadius: 24)

                    Toggle(isOn: $includeMissingIngredients) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Add missing ingredients to grocery list")
                                .font(.recipeRounded(16, weight: .bold))
                                .foregroundStyle(Color.primaryText)
                            Text("Useful when planning ahead for the week.")
                                .font(.recipeRounded(13, weight: .medium))
                                .foregroundStyle(Color.subtleText)
                        }
                    }
                    .tint(.brandGreen)
                    .padding(16)
                    .softCard(cornerRadius: 24)

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Plan Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(selectedDate, selectedSlot, includeMissingIngredients)
                        dismiss()
                    }
                }
            }
        }
    }
}
