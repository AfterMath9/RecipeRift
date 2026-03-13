
//
//  AreaCard.swift
//  RecipeRift
//

import SwiftUI

// A custom ButtonStyle gives the press-scale animation WITHOUT
// blocking the parent ScrollView's pan gesture.
struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

struct AreaCard: View {
    let area: MealArea

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.brandGreenLight)
                    .frame(width: 68, height: 68)
                if let flag = flag(for: area.name) {
                    Text(flag)
                        .font(.system(size: 32))
                } else {
                    Text(abbreviation(for: area.name))
                        .font(.recipeRounded(18, weight: .bold))
                        .foregroundStyle(Color.brandGreen)
                }
            }
            Text(area.name)
                .font(.recipeRounded(14, weight: .semibold))
                .foregroundColor(.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
        }
        .frame(width: 112)
        .padding(.vertical, 16)
        .softCard(cornerRadius: 24)
    }

    // ── Complete flag map: every country TheMealDB has ever returned ─────────
    private func flag(for area: String) -> String? {
        switch area {
        // A
        case "Algerian":          return "🇩🇿"
        case "American":          return "🇺🇸"
        case "Argentinian":       return "🇦🇷"
        case "Australian":        return "🇦🇺"
        // B
        case "Belgian":           return "🇧🇪"
        case "Brazilian":         return "🇧🇷"
        case "British":           return "🇬🇧"
        case "Bulgarian":         return "🇧🇬"
        // C
        case "Canadian":          return "🇨🇦"
        case "Chinese":           return "🇨🇳"
        case "Colombian":         return "🇨🇴"
        case "Croatian":          return "🇭🇷"
        case "Cuban":             return "🇨🇺"
        case "Czech":             return "🇨🇿"
        // D–E
        case "Danish":            return "🇩🇰"
        case "Dutch":             return "🇳🇱"
        case "Egyptian":          return "🇪🇬"
        // F
        case "Filipino":          return "🇵🇭"
        case "Finnish":           return "🇫🇮"
        case "French":            return "🇫🇷"
        // G
        case "German":            return "🇩🇪"
        case "Greek":             return "🇬🇷"
        // H–I
        case "Hungarian":         return "🇭🇺"
        case "Indian":            return "🇮🇳"
        case "Indonesian":        return "🇮🇩"
        case "Iranian", "Persian":return "🇮🇷"
        case "Iraqi":             return "🇮🇶"
        case "Irish":             return "🇮🇪"
        case "Israeli":           return "🇮🇱"
        case "Italian":           return "🇮🇹"
        // J
        case "Jamaican":          return "🇯🇲"
        case "Japanese":          return "🇯🇵"
        // K
        case "Kenyan":            return "🇰🇪"
        case "Korean":            return "🇰🇷"
        // L
        case "Lebanese":          return "🇱🇧"
        case "Libyan":            return "🇱🇾"
        // M
        case "Malaysian":         return "🇲🇾"
        case "Maltese":           return "🇲🇹"
        case "Mexican":           return "🇲🇽"
        case "Moroccan":          return "🇲🇦"
        // N
        case "Nigerian":          return "🇳🇬"
        case "Norwegian":         return "🇳🇴"
        // P
        case "Pakistani":         return "🇵🇰"
        case "Peruvian":          return "🇵🇪"
        case "Polish":            return "🇵🇱"
        case "Portuguese":        return "🇵🇹"
        // R
        case "Romanian":          return "🇷🇴"
        case "Russian":           return "🇷🇺"
        // S
        case "Saudi Arabian", "Saudi": return "🇸🇦"
        case "Slovak", "Slovakian":    return "🇸🇰"
        case "Slovenian":         return "🇸🇮"
        case "Spanish":           return "🇪🇸"
        case "Sri Lankan":        return "🇱🇰"
        case "Swedish":           return "🇸🇪"
        case "Swiss":             return "🇨🇭"
        case "Syrian":            return "🇸🇾"
        // T
        case "Taiwanese":         return "🇹🇼"
        case "Thai":              return "🇹🇭"
        case "Tunisian":          return "🇹🇳"
        case "Turkish":           return "🇹🇷"
        // U
        case "Ukrainian":         return "🇺🇦"
        case "Uruguayan":         return "🇺🇾"
        // V
        case "Venezuelan":        return "🇻🇪"
        case "Vietnamese":        return "🇻🇳"
        // Y
        case "Yemeni":            return "🇾🇪"
        // Fallback
        default:                  return nil
        }
    }

    private func abbreviation(for area: String) -> String {
        let words = area.split(separator: " ")
        if words.count > 1 {
            return words.prefix(2).compactMap { $0.first }.map { String($0) }.joined().uppercased()
        }
        return String(area.prefix(2)).uppercased()
    }
}
