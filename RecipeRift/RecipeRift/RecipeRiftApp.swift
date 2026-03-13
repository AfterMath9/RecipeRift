//
//  RecipeRiftApp.swift
//  RecipeRift
//
//  Created by Amr Mafalani on 2026-02-16.
//

import SwiftUI
import SwiftData
import FirebaseCore
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct RecipeRiftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                if isLoggedIn {
                    ContentView()
                        .transition(.opacity)
                } else {
                    AuthView()
                        .transition(.opacity)
                }
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .modelContainer(for: [
            KitchenIngredient.self,
            SavedRecipe.self,
            GroceryListItem.self,
            MealPlanEntry.self,
            CookLog.self,
            RecipeCollection.self,
            RecentRecipe.self
        ])
    }
}
