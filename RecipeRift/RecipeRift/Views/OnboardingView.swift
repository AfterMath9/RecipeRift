import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var page = 0

    private let items: [OnboardingItem] = [
        .init(
            title: "Track your kitchen",
            subtitle: "Save ingredients, keep your pantry organized, and instantly match recipes to what you already have.",
            icon: "refrigerator.fill"
        ),
        .init(
            title: "Cook with less friction",
            subtitle: "Browse recipes, build grocery lists from missing items, and follow a focused cook mode inside the app.",
            icon: "fork.knife.circle.fill"
        ),
        .init(
            title: "Plan smarter with Pro",
            subtitle: "Unlock meal planning, pantry alerts, photo journals, and unlimited collections when you are ready.",
            icon: "sparkles"
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.softIvory, Color.pageSurface, Color.brandGreenLight.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        hasCompletedOnboarding = true
                    }
                    .font(.recipeRounded(15, weight: .semibold))
                    .foregroundStyle(Color.subtleText)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)

                TabView(selection: $page) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        VStack(spacing: 28) {
                            Spacer(minLength: 20)

                            ZStack {
                                Circle()
                                    .fill(Color.brandGreenLight)
                                    .frame(width: 240, height: 240)
                                Circle()
                                    .fill(Color.cardSurface.opacity(0.8))
                                    .frame(width: 186, height: 186)
                                    .softShadow()
                                Image(systemName: item.icon)
                                    .font(.system(size: 72, weight: .bold))
                                    .foregroundStyle(Color.brandGreen)
                            }

                            VStack(spacing: 12) {
                                Text(item.title)
                                    .font(.recipeRounded(34, weight: .bold))
                                    .foregroundStyle(Color.primaryText)
                                    .multilineTextAlignment(.center)

                                Text(item.subtitle)
                                    .font(.recipeRounded(17, weight: .medium))
                                    .foregroundStyle(Color.subtleText)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(2)
                                    .padding(.horizontal, 8)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 40)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                VStack(spacing: 12) {
                    Button {
                        if page < items.count - 1 {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                page += 1
                            }
                        } else {
                            hasCompletedOnboarding = true
                        }
                    } label: {
                        Text(page == items.count - 1 ? "Get Started" : "Continue")
                            .font(.recipeRounded(18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(Color.brandGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .softShadow()
                    }
                    .buttonStyle(.plain)

                    Text("You can change premium later from Account.")
                        .font(.recipeRounded(13, weight: .medium))
                        .foregroundStyle(Color.subtleText)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

private struct OnboardingItem {
    let title: String
    let subtitle: String
    let icon: String
}
