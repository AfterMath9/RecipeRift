import SwiftUI

struct AccountView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    @AppStorage("displayName") private var displayName = "Chef"
    @AppStorage("proPlan") private var proPlanRawValue = ProPlan.free.rawValue
    @State private var showingPaywall = false

    private var currentPlan: ProPlan {
        PremiumAccess.plan(from: proPlanRawValue)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageSurface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        profileCard
                        planCard
                        featuresCard
                        actionsCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    private var profileCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandGreenLight)
                    .frame(width: 70, height: 70)
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.brandGreen, Color.white)
                    .frame(width: 42, height: 42)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName.isEmpty ? "Chef" : displayName)
                    .font(.recipeRounded(24, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                Text(currentPlan.isPro ? "RecipeRift Pro" : "Free Plan")
                    .font(.recipeRounded(14, weight: .bold))
                    .foregroundStyle(currentPlan.isPro ? Color.brandGreen : Color.subtleText)
            }
            Spacer()
        }
        .padding(20)
        .softCard(cornerRadius: 28)
    }

    private var planCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Subscription")
                .font(.recipeRounded(18, weight: .bold))
                .foregroundStyle(Color.primaryText)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentPlan.title)
                        .font(.recipeRounded(20, weight: .bold))
                        .foregroundStyle(Color.primaryText)
                    Text(currentPlan.isPro ? currentPlan.priceLabel : "Upgrade to unlock pro tools")
                        .font(.recipeRounded(14, weight: .medium))
                        .foregroundStyle(Color.subtleText)
                }
                Spacer()
                Button(currentPlan.isPro ? "Manage" : "Upgrade") {
                    showingPaywall = true
                }
                .font(.recipeRounded(15, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Color.brandGreen)
                .clipShape(Capsule())
            }
        }
        .padding(18)
        .softField(cornerRadius: 24)
    }

    private var featuresCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pro Features")
                .font(.recipeRounded(18, weight: .bold))
                .foregroundStyle(Color.primaryText)

            ForEach(PremiumFeature.allCases) { feature in
                HStack(spacing: 12) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.brandGreen)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.recipeRounded(15, weight: .bold))
                            .foregroundStyle(Color.primaryText)
                        Text(feature.subtitle)
                            .font(.recipeRounded(13, weight: .medium))
                            .foregroundStyle(Color.subtleText)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                .padding(14)
                .softField(cornerRadius: 20)
            }
        }
    }

    private var actionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actions")
                .font(.recipeRounded(18, weight: .bold))
                .foregroundStyle(Color.primaryText)

            Button {
                isLoggedIn = false
                dismiss()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.recipeRounded(15, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .softField(cornerRadius: 20)
            }
            .buttonStyle(.plain)
        }
    }
}
