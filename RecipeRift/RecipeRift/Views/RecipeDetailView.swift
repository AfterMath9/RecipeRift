//
//  RecipeDetailView.swift
//  RecipeRift
//

import SwiftUI
import SwiftData
import WebKit

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("proPlan") private var proPlanRawValue = ProPlan.free.rawValue
    @State private var vm: RecipeDetailsViewModel?
    @State private var selectedTab = 0
    @State private var showingCamera = false
    @State private var showingVideoPlayer = false
    @State private var showingPlanner = false
    @State private var showingCollections = false
    @State private var showingCookMode = false
    @State private var lockedFeature: PremiumFeature?
    @State private var showingPaywall = false
    @State private var contentShown = false

    let recipeID: String

    private var isPro: Bool { PremiumAccess.plan(from: proPlanRawValue).isPro }

    var body: some View {
        ZStack(alignment: .top) {
            Color.pageSurface.ignoresSafeArea()

            if let vm = vm {
                if vm.isLoading {
                    VStack(spacing: 14) {
                        ProgressView().tint(.brandGreen).scaleEffect(1.3)
                        Text("Loading recipe…")
                            .font(.recipeRounded(15, weight: .medium))
                            .foregroundColor(.subtleText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let details = vm.fullRecipeDetails {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            detailHero(details: details)

                            VStack(alignment: .leading, spacing: 22) {
                                Capsule()
                                    .fill(Color.borderSoft)
                                    .frame(width: 74, height: 7)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 14)

                                titleBlock(details: details, vm: vm)
                                quickMeta(details: details, vm: vm)
                                saveActions(vm: vm)
                                utilityActions(details: details, vm: vm)
                                pantryMatchSection(vm: vm)
                                tabSwitcher
                                tabContent(details: details, vm: vm)

                                if details.videoLink != nil {
                                    Button {
                                        showingVideoPlayer = true
                                    } label: {
                                        HStack(spacing: 10) {
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: 18))
                                            Text("Watch Videos")
                                                .font(.recipeRounded(17, weight: .bold))
                                        }
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.brandGreen)
                                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .softShadow()
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, 4)
                                    .padding(.bottom, 28)
                                }
                            }
                            .padding(.horizontal, 20)
                            .background(
                                UnevenRoundedRectangle(
                                    cornerRadii: .init(topLeading: 34, topTrailing: 34)
                                )
                                .fill(Color.cardSurface)
                                .overlay(
                                    UnevenRoundedRectangle(
                                        cornerRadii: .init(topLeading: 34, topTrailing: 34)
                                    )
                                    .stroke(Color.borderSoft, lineWidth: 1)
                                )
                                .softShadow()
                            )
                            .offset(y: -26)
                            .padding(.bottom, -26)
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                    .opacity(contentShown ? 1 : 0)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.35)) { contentShown = true }
                    }
                } else if let err = vm.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 44))
                            .foregroundColor(.orange)
                        Text(err)
                            .font(.recipeRounded(16, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.subtleText)
                        Button("Try Again") { Task { await vm.loadRecipeFromAPI() } }
                            .font(.recipeRounded(16, weight: .bold))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.brandGreen)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(40)
                }
            } else {
                ProgressView()
                    .tint(.brandGreen)
                    .onAppear {
                        vm = RecipeDetailsViewModel(databaseContext: modelContext, recipeID: recipeID)
                    }
            }

            topButtons
        }
        .navigationBarHidden(true)
        .enableSwipeBack()
        .sheet(isPresented: $showingCamera) {
            CameraPickerView { image in
                if let imageData = image.jpegData(compressionQuality: 0.85) {
                    vm?.saveUserPhoto(imageData)
                }
            }
        }
        .sheet(isPresented: $showingVideoPlayer) {
            if let videoURLString = vm?.fullRecipeDetails?.videoLink {
                YouTubePlayerSheet(videoURLString: videoURLString)
            }
        }
        .sheet(isPresented: $showingPlanner) {
            AddMealPlanSheet { date, slot, includeMissing in
                vm?.addMealPlanEntry(for: date, mealSlot: slot, includeMissingIngredients: includeMissing)
            }
        }
        .sheet(isPresented: $showingCollections) {
            if let recipe = vm?.savedRecipe {
                CollectionPickerSheet(recipe: recipe)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(focusFeature: lockedFeature)
        }
        .fullScreenCover(isPresented: $showingCookMode) {
            CookModeView(
                recipeName: vm?.fullRecipeDetails?.recipeName ?? "",
                ingredients: vm?.fullRecipeDetails?.getAllIngredients() ?? [],
                steps: instructionSteps(from: vm?.fullRecipeDetails?.cookingSteps)
            )
        }
        .task {
            if vm == nil {
                vm = RecipeDetailsViewModel(databaseContext: modelContext, recipeID: recipeID)
            }
            await vm?.loadRecipeFromAPI()
        }
    }

    @ViewBuilder
    private func detailHero(details: RecipeDetails) -> some View {
        AsyncImage(url: URL(string: details.pictureURL ?? "")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                LinearGradient(
                    colors: [Color.softIvory, Color.brandGreenLight],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.brandGreen.opacity(0.45))
                )
            }
        }
        .frame(height: 390)
        .clipped()
    }

    private func titleBlock(details: RecipeDetails, vm: RecipeDetailsViewModel) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(details.recipeName)
                    .font(.recipeRounded(30, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                    .lineLimit(2)

                Text(details.cuisineType ?? "Chef's table")
                    .font(.recipeRounded(17, weight: .medium))
                    .foregroundStyle(Color.subtleText)
            }

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.brandGold)
                Text(vm.savedRecipe?.userRating.map { "\($0).0" } ?? "Rate")
                    .font(.recipeRounded(17, weight: .bold))
                    .foregroundStyle(Color.primaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.elevatedSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private func quickMeta(details: RecipeDetails, vm: RecipeDetailsViewModel) -> some View {
        HStack(spacing: 10) {
            DetailMetaPill(icon: "list.bullet", text: "\(details.getAllIngredients().count) items")
            DetailMetaPill(icon: "globe.europe.africa.fill", text: details.cuisineType ?? "Global")
            DetailMetaPill(icon: vm.canUserMakeThisRecipe() ? "checkmark.seal.fill" : "basket.fill", text: vm.canUserMakeThisRecipe() ? "Ready to cook" : "Need items")
        }
    }

    private func saveActions(vm: RecipeDetailsViewModel) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    vm.toggleBookmark()
                }
            } label: {
                Label(
                    vm.savedRecipe != nil ? "Bookmarked" : "Bookmark",
                    systemImage: vm.savedRecipe != nil ? "bookmark.fill" : "bookmark"
                )
                .font(.recipeRounded(15, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(vm.savedRecipe != nil ? Color.brandGreen : Color.elevatedSurface)
                .foregroundStyle(vm.savedRecipe != nil ? Color.white : Color.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)

            Button { vm.markRecipeAsCooked() } label: {
                Label("Mark Cooked", systemImage: "checkmark.seal.fill")
                    .font(.recipeRounded(15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.elevatedSurface)
                    .foregroundStyle(vm.savedRecipe?.hasCooked == true ? Color.brandGreen : Color.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private func utilityActions(details: RecipeDetails, vm: RecipeDetailsViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                utilityButton(icon: "cart.badge.plus", title: "Add Missing") {
                    vm.addMissingIngredientsToGroceryList()
                }
                utilityButton(icon: "calendar.badge.plus", title: "Plan Meal") {
                    if isPro {
                        showingPlanner = true
                    } else {
                        lockedFeature = .mealPlanner
                        showingPaywall = true
                    }
                }
                utilityButton(icon: "rectangle.inset.filled.and.person.filled", title: "Cook Mode") {
                    showingCookMode = true
                }
                utilityButton(icon: "square.grid.2x2.fill", title: "Collections") {
                    if vm.savedRecipe == nil {
                        vm.addBookmark()
                    }
                    showingCollections = vm.savedRecipe != nil
                }
            }
        }
    }

    private func utilityButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.recipeRounded(14, weight: .bold))
            }
            .foregroundStyle(Color.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.elevatedSurface)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func pantryMatchSection(vm: RecipeDetailsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Kitchen Match")
                .font(.recipeRounded(18, weight: .bold))
                .foregroundStyle(Color.primaryText)

            HStack(spacing: 12) {
                pantryColumn(
                    title: "You Have",
                    tint: .brandGreen,
                    items: vm.getAvailableIngredientPairs()
                )
                pantryColumn(
                    title: "Need To Buy",
                    tint: .brandGold,
                    items: vm.getMissingIngredientPairs()
                )
            }
        }
    }

    private func pantryColumn(title: String, tint: Color, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.recipeRounded(15, weight: .bold))
                .foregroundStyle(tint)

            if items.isEmpty {
                Text("None")
                    .font(.recipeRounded(14, weight: .medium))
                    .foregroundStyle(Color.subtleText)
            } else {
                ForEach(Array(items.prefix(4).enumerated()), id: \.offset) { _, item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.0)
                            .font(.recipeRounded(14, weight: .bold))
                            .foregroundStyle(Color.primaryText)
                            .lineLimit(1)
                        if !item.1.isEmpty {
                            Text(item.1)
                                .font(.recipeRounded(12, weight: .medium))
                                .foregroundStyle(Color.subtleText)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .softField(cornerRadius: 20)
    }

    private var tabSwitcher: some View {
        HStack(spacing: 10) {
            detailTabButton(title: "Ingredients", index: 0)
            detailTabButton(title: "Instructions", index: 1)
            detailTabButton(title: "Notes", index: 2)
        }
    }

    private func detailTabButton(title: String, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedTab = index
            }
        } label: {
            Text(title)
                .font(.recipeRounded(14, weight: .bold))
                .foregroundStyle(selectedTab == index ? Color.white : Color.subtleText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTab == index ? Color.brandGreen : Color.elevatedSurface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func tabContent(details: RecipeDetails, vm: RecipeDetailsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if selectedTab == 0 {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Ingredients")
                        .font(.recipeRounded(18, weight: .bold))
                        .foregroundStyle(Color.primaryText)
                    IngredientsTab(details: details, userHas: vm.getIngredientsThatUserHas())
                }
            } else if selectedTab == 1 {
                let description = firstInstructionLine(from: details.cookingSteps)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Description")
                        .font(.recipeRounded(18, weight: .bold))
                        .foregroundStyle(Color.primaryText)
                    Text(description)
                        .font(.recipeRounded(16, weight: .medium))
                        .foregroundStyle(Color.subtleText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Instructions")
                        .font(.recipeRounded(18, weight: .bold))
                        .foregroundStyle(Color.primaryText)
                    InstructionsTab(steps: details.cookingSteps ?? "")
                }
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Your Notes")
                        .font(.recipeRounded(18, weight: .bold))
                        .foregroundStyle(Color.primaryText)
                    NotesTab(
                        notes: Binding(
                            get: { vm.savedRecipe?.userNotes ?? "" },
                            set: { vm.saveUserNotes($0) }
                        ),
                        onCamera: {
                            if isPro {
                                showingCamera = true
                            } else {
                                lockedFeature = .photoJournal
                                showingPaywall = true
                            }
                        },
                        photoData: vm.savedRecipe?.userPhotoData,
                        difficulty: Binding(
                            get: { vm.savedRecipe?.personalDifficulty ?? "Medium" },
                            set: { vm.savePersonalDifficulty($0) }
                        ),
                        prepMinutes: Binding(
                            get: { vm.savedRecipe?.personalPrepMinutes ?? 20 },
                            set: { vm.savePersonalPrepMinutes($0) }
                        ),
                        servings: Binding(
                            get: { vm.savedRecipe?.personalServings ?? 2 },
                            set: { vm.savePersonalServings($0) }
                        ),
                        onSaveJournal: {
                            if isPro {
                                vm.saveCookLogFromCurrentNotes()
                            } else {
                                lockedFeature = .photoJournal
                                showingPaywall = true
                            }
                        },
                        cookLogs: vm.getCookLogs(),
                        isPro: isPro,
                        onUnlock: {
                            lockedFeature = .photoJournal
                            showingPaywall = true
                        }
                    )
                }
            }
        }
    }

    private func instructionSteps(from text: String?) -> [String] {
        let steps = (text ?? "")
            .components(separatedBy: "\r\n")
            .flatMap { $0.components(separatedBy: "\n") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return steps.isEmpty ? ["No instructions available."] : steps
    }

    private func firstInstructionLine(from steps: String?) -> String {
        let firstLine = steps?
            .components(separatedBy: .newlines)
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let firstLine, !firstLine.isEmpty {
            return firstLine
        }

        return "A simple step-by-step guide for making this recipe."
    }

    private var topButtons: some View {
        VStack {
            HStack {
                Button { dismiss() } label: {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.46))
                            .frame(width: 44, height: 44)
                        Circle()
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                            .frame(width: 44, height: 44)
                        Image(systemName: "arrow.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.white)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                if let vm = vm {
                    Button { vm.toggleBookmark() } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.46))
                                .frame(width: 44, height: 44)
                            Circle()
                                .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                .frame(width: 44, height: 44)
                            Image(systemName: vm.savedRecipe != nil ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(vm.savedRecipe != nil ? Color.brandGreenLight : Color.white)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 58)

            Spacer()
        }
    }
}

private struct DetailMetaPill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
            Text(text)
                .font(.recipeRounded(14, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(Color.subtleText)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.elevatedSurface)
        .clipShape(Capsule())
    }
}

private struct IngredientThumbnail: View {
    let name: String
    let userOwns: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(userOwns ? Color.brandGreenLight : Color.elevatedSurface)
                .frame(width: 26, height: 26)

            if let url = RecipeAPIService.shared.ingredientImageURL(name: name) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(4)
                    } else {
                        fallbackIcon
                    }
                }
            } else {
                fallbackIcon
            }
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: userOwns ? "checkmark" : "fork.knife")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(userOwns ? Color.brandGreen : Color.subtleText)
    }
}

private struct IngredientsTab: View {
    let details: RecipeDetails
    let userHas: [String]

    var body: some View {
        let ingredients = details.getAllIngredients()
        let measurements = details.getAllMeasurements()

        VStack(spacing: 10) {
            ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                let measure = index < measurements.count ? measurements[index] : ""
                let userOwns = userHas.contains(where: { $0.lowercased() == ingredient.lowercased() })

                HStack(spacing: 8) {
                    IngredientThumbnail(name: ingredient, userOwns: userOwns)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(ingredient)
                            .font(.recipeRounded(13, weight: .bold))
                            .foregroundStyle(Color.primaryText)
                            .lineLimit(2)
                        if !measure.isEmpty {
                            Text(measure)
                                .font(.recipeRounded(11, weight: .medium))
                                .foregroundStyle(Color.subtleText)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .softField(cornerRadius: 16)
            }
        }
    }
}

private struct InstructionsTab: View {
    let steps: String

    var body: some View {
        let paragraphs = steps
            .components(separatedBy: "\r\n")
            .flatMap { $0.components(separatedBy: "\n") }
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle().fill(Color.brandGreen).frame(width: 30, height: 30)
                        Text("\(index + 1)")
                            .font(.recipeRounded(13, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    Text(step)
                        .font(.recipeRounded(16, weight: .medium))
                        .foregroundStyle(Color.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .softField(cornerRadius: 20)
            }
        }
    }
}

private struct NotesTab: View {
    @Binding var notes: String
    let onCamera: () -> Void
    let photoData: Data?
    @Binding var difficulty: String
    @Binding var prepMinutes: Int
    @Binding var servings: Int
    let onSaveJournal: () -> Void
    let cookLogs: [CookLog]
    let isPro: Bool
    let onUnlock: () -> Void

    private let difficultyOptions = ["Easy", "Medium", "Hard"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextEditor(text: $notes)
                .frame(minHeight: 150)
                .font(.recipeRounded(16, weight: .medium))
                .foregroundStyle(Color.primaryText)
                .scrollContentBackground(.hidden)
                .padding(12)
                .softField(cornerRadius: 20)

            if isPro {
                Button(action: onCamera) {
                    Label("Add Photo", systemImage: "camera.fill")
                        .font(.recipeRounded(15, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.elevatedSurface)
                        .foregroundStyle(Color.brandGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                Button(action: onUnlock) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 13, weight: .bold))
                        Text("Upgrade for Photo Journal")
                            .font(.recipeRounded(15, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.elevatedSurface)
                    .foregroundStyle(Color.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Cooking Details")
                    .font(.recipeRounded(16, weight: .bold))
                    .foregroundStyle(Color.primaryText)

                Picker("Difficulty", selection: $difficulty) {
                    ForEach(difficultyOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                HStack(spacing: 12) {
                    Stepper(value: $prepMinutes, in: 5...240, step: 5) {
                        Text("Prep \(prepMinutes) mins")
                            .font(.recipeRounded(14, weight: .bold))
                            .foregroundStyle(Color.primaryText)
                    }
                    Stepper(value: $servings, in: 1...12) {
                        Text("Serves \(servings)")
                            .font(.recipeRounded(14, weight: .bold))
                            .foregroundStyle(Color.primaryText)
                    }
                }
            }
            .padding(16)
            .softField(cornerRadius: 20)

            Button(action: isPro ? onSaveJournal : onUnlock) {
                Label(isPro ? "Save To Cook Journal" : "Unlock Cook Journal", systemImage: isPro ? "book.closed.fill" : "lock.fill")
                    .font(.recipeRounded(15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isPro ? Color.brandGreen : Color.elevatedSurface)
                    .foregroundStyle(isPro ? .white : Color.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)

            if let data = photoData, let uiImg = UIImage(data: data) {
                Image(uiImage: uiImg)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }

            if isPro, !cookLogs.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cook Journal")
                        .font(.recipeRounded(16, weight: .bold))
                        .foregroundStyle(Color.primaryText)

                    ForEach(Array(cookLogs.prefix(3))) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(log.cookedAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.recipeRounded(12, weight: .bold))
                                .foregroundStyle(Color.brandGreen)

                            if let notes = log.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.recipeRounded(14, weight: .medium))
                                    .foregroundStyle(Color.primaryText)
                                    .lineLimit(3)
                            } else {
                                Text("Cooked and saved.")
                                    .font(.recipeRounded(14, weight: .medium))
                                    .foregroundStyle(Color.subtleText)
                            }
                        }
                        .padding(14)
                        .softField(cornerRadius: 18)
                    }
                }
            } else if !isPro {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cook Journal")
                        .font(.recipeRounded(16, weight: .bold))
                        .foregroundStyle(Color.primaryText)
                    Text("Save photos, notes, and made-it history with Pro.")
                        .font(.recipeRounded(14, weight: .medium))
                        .foregroundStyle(Color.subtleText)
                }
                .padding(14)
                .softField(cornerRadius: 18)
                .onTapGesture(perform: onUnlock)
            }
        }
    }
}

private struct YouTubePlayerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let videoURLString: String

    var body: some View {
        NavigationStack {
            YouTubeWebPlayer(videoURLString: videoURLString)
                .background(Color.black.ignoresSafeArea())
                .navigationTitle("Video")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

private struct YouTubeWebPlayer: UIViewRepresentable {
    let videoURLString: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false

        if let embedURL = embedURLString(from: videoURLString) {
            let html = """
            <!doctype html>
            <html>
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
              <style>
                html, body {
                  margin: 0;
                  padding: 0;
                  width: 100%;
                  height: 100%;
                  background: #000;
                  overflow: hidden;
                }
                iframe {
                  position: fixed;
                  inset: 0;
                  width: 100%;
                  height: 100%;
                  border: 0;
                }
              </style>
            </head>
            <body>
              <iframe
                src="\(embedURL)"
                title="YouTube video player"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                allowfullscreen
                playsinline="1"></iframe>
            </body>
            </html>
            """
            webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private func embedURLString(from urlString: String) -> String? {
        guard let components = URLComponents(string: urlString) else { return nil }

        if let host = components.host, host.contains("youtube.com"),
           let videoID = components.queryItems?.first(where: { $0.name == "v" })?.value {
            return "https://www.youtube.com/embed/\(videoID)?playsinline=1&rel=0&modestbranding=1"
        }

        if let host = components.host, host.contains("youtu.be") {
            let videoID = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if !videoID.isEmpty {
                return "https://www.youtube.com/embed/\(videoID)?playsinline=1&rel=0&modestbranding=1"
            }
        }

        return nil
    }
}
