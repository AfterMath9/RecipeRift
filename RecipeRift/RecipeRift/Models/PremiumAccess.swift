import Foundation

enum ProPlan: String, CaseIterable, Identifiable {
    case free
    case monthly
    case yearly
    case lifetime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .free: return "Free"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }

    var priceLabel: String {
        switch self {
        case .free: return "Current"
        case .monthly: return "$4.99 / month"
        case .yearly: return "$39.99 / year"
        case .lifetime: return "$79.99 once"
        }
    }

    var badge: String? {
        switch self {
        case .yearly: return "Best Value"
        case .lifetime: return "One-Time"
        default: return nil
        }
    }

    var isPro: Bool { self != .free }
}

enum PremiumFeature: String, CaseIterable, Identifiable {
    case mealPlanner
    case pantryAlerts
    case photoJournal
    case unlimitedCollections

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mealPlanner: return "Meal Planner"
        case .pantryAlerts: return "Smart Pantry Alerts"
        case .photoJournal: return "Photo Cook Journal"
        case .unlimitedCollections: return "Unlimited Collections"
        }
    }

    var subtitle: String {
        switch self {
        case .mealPlanner: return "Plan recipes by day and auto-build your shopping flow."
        case .pantryAlerts: return "Get expiry nudges and faster use-it-now recipe suggestions."
        case .photoJournal: return "Save made-it notes, pictures, ratings, and cooking history."
        case .unlimitedCollections: return "Create unlimited custom folders for your saved recipes."
        }
    }

    var icon: String {
        switch self {
        case .mealPlanner: return "calendar.badge.plus"
        case .pantryAlerts: return "bell.badge.fill"
        case .photoJournal: return "camera.fill"
        case .unlimitedCollections: return "square.grid.2x2.fill"
        }
    }
}

enum PremiumAccess {
    static func plan(from rawValue: String) -> ProPlan {
        ProPlan(rawValue: rawValue) ?? .free
    }
}
