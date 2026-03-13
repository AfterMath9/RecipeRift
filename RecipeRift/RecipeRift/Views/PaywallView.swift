import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("proPlan") private var proPlanRawValue = ProPlan.free.rawValue
    @State private var selectedPlan: ProPlan = .yearly

    var focusFeature: PremiumFeature?

    private var currentPlan: ProPlan {
        PremiumAccess.plan(from: proPlanRawValue)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageSurface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        featureList
                        plansSection
                        footerNote
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                }
            }
            .navigationTitle("RecipeRift Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    Button {
                        proPlanRawValue = selectedPlan.rawValue
                        dismiss()
                    } label: {
                        Text(currentPlan == selectedPlan ? "Current Plan" : "Continue with \(selectedPlan.title)")
                            .font(.recipeRounded(17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(currentPlan == selectedPlan ? Color.subtleText : Color.brandGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(currentPlan == selectedPlan)

                    Text("Billing hookup comes next once product IDs are ready.")
                        .font(.recipeRounded(12, weight: .medium))
                        .foregroundStyle(Color.subtleText)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 18)
                .background(Color.pageSurface)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text("Unlock planning, journaling, and premium kitchen tools.")
                    .font(.recipeRounded(30, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                Spacer(minLength: 0)
            }

            if let focusFeature {
                HStack(spacing: 8) {
                    Image(systemName: focusFeature.icon)
                        .font(.system(size: 14, weight: .bold))
                    Text("You opened \(focusFeature.title)")
                        .font(.recipeRounded(14, weight: .bold))
                }
                .foregroundStyle(Color.brandGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.brandGreenLight)
                .clipShape(Capsule())
            }
        }
        .padding(22)
        .softCard(cornerRadius: 30)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Included in Pro")
                .font(.recipeRounded(18, weight: .bold))
                .foregroundStyle(Color.primaryText)

            ForEach(PremiumFeature.allCases) { feature in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.brandGreenLight)
                            .frame(width: 38, height: 38)
                        Image(systemName: feature.icon)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.brandGreen)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.title)
                            .font(.recipeRounded(16, weight: .bold))
                            .foregroundStyle(Color.primaryText)
                        Text(feature.subtitle)
                            .font(.recipeRounded(14, weight: .medium))
                            .foregroundStyle(Color.subtleText)
                    }
                    Spacer()
                }
                .padding(14)
                .softField(cornerRadius: 22)
            }
        }
    }

    private var plansSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Choose your plan")
                .font(.recipeRounded(18, weight: .bold))
                .foregroundStyle(Color.primaryText)

            ForEach([ProPlan.monthly, .yearly, .lifetime]) { plan in
                Button {
                    selectedPlan = plan
                } label: {
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(plan.title)
                                    .font(.recipeRounded(18, weight: .bold))
                                    .foregroundStyle(Color.primaryText)
                                if let badge = plan.badge {
                                    Text(badge)
                                        .font(.recipeRounded(11, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .background(Color.brandGreen)
                                        .clipShape(Capsule())
                                }
                            }

                            Text(plan.priceLabel)
                                .font(.recipeRounded(14, weight: .medium))
                                .foregroundStyle(Color.subtleText)
                        }

                        Spacer()

                        Image(systemName: selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(selectedPlan == plan ? Color.brandGreen : Color.subtleText)
                    }
                    .padding(18)
                    .background(selectedPlan == plan ? Color.brandGreenLight : Color.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(selectedPlan == plan ? Color.brandGreen.opacity(0.4) : Color.borderSoft, lineWidth: 1)
                    )
                    .softShadow()
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var footerNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Free version keeps the essentials.")
                .font(.recipeRounded(16, weight: .bold))
                .foregroundStyle(Color.primaryText)
            Text("Free stays focused on pantry management, basic recipe discovery, bookmarks, and core cooking flow.")
                .font(.recipeRounded(14, weight: .medium))
                .foregroundStyle(Color.subtleText)
        }
        .padding(18)
        .softField(cornerRadius: 24)
    }
}
