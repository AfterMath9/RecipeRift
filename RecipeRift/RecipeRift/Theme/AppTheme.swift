
//
//  AppTheme.swift
//  RecipeRift
//

import SwiftUI

// MARK: - Brand Colors
extension Color {
    static let brandGreen      = Color(red: 0.111, green: 0.678, blue: 0.402)
    static let brandGreenLight = Color(red: 0.885, green: 0.973, blue: 0.924)
    static let brandGreenDark  = Color(red: 0.067, green: 0.424, blue: 0.237)
    static let brandGold       = Color(red: 0.964, green: 0.751, blue: 0.152)
    static let softIvory       = Color(red: 0.973, green: 0.969, blue: 0.953)
    static let mistGray        = Color(red: 0.934, green: 0.934, blue: 0.918)

    // Adaptive surfaces
    static let cardSurface = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.12, blue: 0.11, alpha: 1)
            : UIColor.white
    })
    static let pageSurface = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.08, green: 0.08, blue: 0.07, alpha: 1)
            : UIColor(red: 0.964, green: 0.961, blue: 0.949, alpha: 1)
    })
    static let chipSurface = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.15, blue: 0.14, alpha: 1)
            : UIColor(red: 0.974, green: 0.973, blue: 0.968, alpha: 1)
    })
    static let elevatedSurface = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.14, green: 0.14, blue: 0.13, alpha: 1)
            : UIColor(red: 0.991, green: 0.990, blue: 0.985, alpha: 1)
    })
    static let borderSoft = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 1.0, alpha: 0.06)
            : UIColor(red: 0.915, green: 0.912, blue: 0.896, alpha: 1)
    })
    static let subtleText = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.68, alpha: 1)
            : UIColor(red: 0.496, green: 0.488, blue: 0.465, alpha: 1)
    })
    static let primaryText = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.97, alpha: 1)
            : UIColor(red: 0.121, green: 0.121, blue: 0.117, alpha: 1)
    })
}

// MARK: - Typography
extension Font {
    static func recipeRounded(_ size: CGFloat, weight: Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Shadow helpers
extension View {
    func cardShadow(radius: CGFloat = 8, y: CGFloat = 4) -> some View {
        self.shadow(color: Color.black.opacity(0.06), radius: radius, x: 0, y: y)
    }
    func softShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)
    }
    /// Liquid glass shadow — stronger, used on the tab bar pill
    func glassShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.28), radius: 22, x: 0, y: 10)
    }
    func softCard(cornerRadius: CGFloat = 24, border: Bool = true) -> some View {
        self
            .background(Color.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                if border {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.borderSoft, lineWidth: 1)
                }
            }
            .softShadow()
    }
    func softField(cornerRadius: CGFloat = 18) -> some View {
        self
            .background(Color.elevatedSurface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.borderSoft, lineWidth: 1)
            )
    }
}

// MARK: - Shared UI
struct AppSectionHeader: View {
    let title: String
    var actionTitle: String? = "See all"

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.recipeRounded(18, weight: .bold))
                .foregroundStyle(Color.primaryText)
            Spacer()
            if let actionTitle {
                Text(actionTitle)
                    .font(.recipeRounded(15, weight: .semibold))
                    .foregroundStyle(Color.brandGreen)
            }
        }
    }
}

// MARK: - Reusable Button Styles
struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
