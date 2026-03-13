import SwiftUI

struct CookModeView: View {
    @Environment(\.dismiss) private var dismiss
    let recipeName: String
    let ingredients: [String]
    let steps: [String]

    @State private var checkedIngredients: Set<String> = []
    @State private var stepIndex = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageSurface.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    Text(recipeName)
                        .font(.recipeRounded(30, weight: .bold))
                        .foregroundStyle(Color.primaryText)

                    Text("Step \(min(stepIndex + 1, max(steps.count, 1)))/\(max(steps.count, 1))")
                        .font(.recipeRounded(14, weight: .bold))
                        .foregroundStyle(Color.brandGreen)

                    Text(steps.indices.contains(stepIndex) ? steps[stepIndex] : "No instructions available.")
                        .font(.recipeRounded(22, weight: .medium))
                        .foregroundStyle(Color.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(22)
                        .softCard(cornerRadius: 28)

                    Text("Ingredient Checklist")
                        .font(.recipeRounded(18, weight: .bold))
                        .foregroundStyle(Color.primaryText)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(ingredients, id: \.self) { ingredient in
                                Button {
                                    if checkedIngredients.contains(ingredient) {
                                        checkedIngredients.remove(ingredient)
                                    } else {
                                        checkedIngredients.insert(ingredient)
                                    }
                                } label: {
                                    HStack {
                                        Text(ingredient)
                                            .font(.recipeRounded(16, weight: .bold))
                                            .foregroundStyle(Color.primaryText)
                                        Spacer()
                                        Image(systemName: checkedIngredients.contains(ingredient) ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 20))
                                            .foregroundStyle(checkedIngredients.contains(ingredient) ? Color.brandGreen : Color.subtleText)
                                    }
                                    .padding(16)
                                    .softField(cornerRadius: 20)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 8)
                    }

                    HStack(spacing: 12) {
                        Button("Previous") {
                            stepIndex = max(stepIndex - 1, 0)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.elevatedSurface)
                        .foregroundStyle(Color.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                        Button(stepIndex >= max(steps.count - 1, 0) ? "Finish" : "Next") {
                            if stepIndex < steps.count - 1 {
                                stepIndex += 1
                            } else {
                                dismiss()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.brandGreen)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .font(.recipeRounded(16, weight: .bold))
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
