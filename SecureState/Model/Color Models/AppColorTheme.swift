//
//  AppColorTheme.swift
//  SecureState
//
//  Created by Sam Greenhill on 11/7/25.
//

import Foundation
import SwiftUI

enum AppColorTheme: String, CaseIterable, Codable {
    case `default` = "Classic"
    case midnight = "Midnight Aurora"
    case sunset = "Sunset Blaze"
    case forest = "Forest Whisper"
    case ocean = "Ocean Depths"
    case lavender = "Lavender Dreams"
    case crimson = "Crimson Fire"
    case arctic = "Arctic Frost"
    case amber = "Amber Glow"
    case sapphire = "Sapphire Elegance"
    case emerald = "Emerald Garden"

    var displayName: String {
        return self.rawValue
    }

    var description: String {
        switch self {
        case .default:
            return "Original SecureState colors"
        case .midnight:
            return "Deep purples and blues with cosmic accents"
        case .sunset:
            return "Warm oranges and reds with golden highlights"
        case .forest:
            return "Rich greens with earthy brown undertones"
        case .ocean:
            return "Deep blues and teals with seafoam accents"
        case .lavender:
            return "Soft purples and pinks with gentle gradients"
        case .crimson:
            return "Bold reds and deep pinks with rose gold"
        case .arctic:
            return "Cool whites and icy blues with silver"
        case .amber:
            return "Golden yellows and warm browns"
        case .sapphire:
            return "Royal blues and indigos with platinum"
        case .emerald:
            return "Vibrant greens with jade accents"
        }
    }

    var previewGradient: LinearGradient {
        LinearGradient(
            colors: [primary, accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // Core theme colors
    var primary: Color {
        switch self {
        case .default:
            return Color.adaptive(
                light: UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1),  // Indigo
                dark: UIColor(red: 120/255, green: 118/255, blue: 255/255, alpha: 1)   // Lighter indigo
            )
        case .midnight:
            return Color.adaptive(
                light: UIColor(red: 80/255, green: 40/255, blue: 160/255, alpha: 1),
                dark: UIColor(red: 140/255, green: 100/255, blue: 220/255, alpha: 1)) // Lighter in dark mod // Rich purple
        case .sunset:
            return Color.adaptive(
                light: UIColor(red: 220/255, green: 80/255, blue: 45/255, alpha: 1), // Toned down
                dark: UIColor(red: 200/255, green: 70/255, blue: 50/255, alpha: 1)) // Fiery orange
        case .forest:
            return Color.adaptive(
                light: UIColor(red: 30/255, green: 160/255, blue: 80/255, alpha: 1),
                dark: UIColor(red: 20/255, green: 120/255, blue: 60/255, alpha: 1)) // Forest green
        case .ocean:
            return Color.adaptive(
                light: UIColor(red: 20/255, green: 100/255, blue: 180/255, alpha: 1),
                dark: UIColor(red: 80/255, green: 160/255, blue: 240/255, alpha: 1)) // Lighter blue for dark mode
        case .lavender:
            return Color.adaptive(
                light: UIColor(red: 180/255, green: 120/255, blue: 240/255, alpha: 1),
                dark: UIColor(red: 200/255, green: 140/255, blue: 255/255, alpha: 1)) // Lavender
        case .crimson:
            return Color.adaptive(
                light: UIColor(red: 220/255, green: 40/255, blue: 70/255, alpha: 1),
                dark: UIColor(red: 170/255, green: 30/255, blue: 55/255, alpha: 1)) // Crimson
        case .arctic:
            return Color.adaptive(
                light: UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 1),
                dark: UIColor(red: 100/255, green: 160/255, blue: 200/255, alpha: 1)) // Ice blue
        case .amber:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 190/255, blue: 70/255, alpha: 1),
                dark: UIColor(red: 200/255, green: 140/255, blue: 50/255, alpha: 1)) // Golden
        case .sapphire:
            return Color.adaptive(
                light: UIColor(red: 60/255, green: 100/255, blue: 200/255, alpha: 1),
                dark: UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1)) // Much lighter for visibility
        case .emerald:
            return Color.adaptive(
                light: UIColor(red: 40/255, green: 200/255, blue: 110/255, alpha: 1),
                dark: UIColor(red: 25/255, green: 145/255, blue: 80/255, alpha: 1)) // Vibrant green
        }
    }

    var accent: Color {
        switch self {
        case .default:
            return Color.adaptive(
                light: UIColor(red: 0/255, green: 199/255, blue: 190/255, alpha: 1),  // Cyan/teal
                dark: UIColor(red: 100/255, green: 210/255, blue: 255/255, alpha: 1)  // Light cyan
            )
        case .midnight:
            return Color.adaptive(
                light: UIColor(red: 160/255, green: 80/255, blue: 255/255, alpha: 1),
                dark: UIColor(red: 120/255, green: 50/255, blue: 215/255, alpha: 1)) // Electric violet
        case .sunset:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 120/255, blue: 180/255, alpha: 1),
                dark: UIColor(red: 220/255, green: 80/255, blue: 150/255, alpha: 1)) // Magenta
        case .forest:
            return Color.adaptive(
                light: UIColor(red: 30/255, green: 160/255, blue: 80/255, alpha: 1),
                dark: UIColor(red: 40/255, green: 180/255, blue: 100/255, alpha: 1)) // Brighter in dark mode
        case .ocean:
            return Color.adaptive(
                light: UIColor(red: 50/255, green: 190/255, blue: 220/255, alpha: 1),
                dark: UIColor(red: 30/255, green: 140/255, blue: 160/255, alpha: 1)) // Teal-blue
        case .lavender:
            return Color.adaptive(
                light: UIColor(red: 230/255, green: 170/255, blue: 250/255, alpha: 1),
                dark: UIColor(red: 190/255, green: 120/255, blue: 230/255, alpha: 1)) // Pink-lilac
        case .crimson:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 90/255, blue: 140/255, alpha: 1),
                dark: UIColor(red: 220/255, green: 60/255, blue: 120/255, alpha: 1)) // Deep rose
        case .arctic:
            return Color.adaptive(
                light: UIColor(red: 170/255, green: 210/255, blue: 240/255, alpha: 1),
                dark: UIColor(red: 120/255, green: 180/255, blue: 220/255, alpha: 1))
        case .amber:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 210/255, blue: 130/255, alpha: 1),
                dark: UIColor(red: 220/255, green: 180/255, blue: 100/255, alpha: 1)) // Warm orange
        case .sapphire:
            return Color.adaptive(
                light: UIColor(red: 130/255, green: 170/255, blue: 250/255, alpha: 1),
                dark: UIColor(red: 100/255, green: 130/255, blue: 220/255, alpha: 1)) // Indigo
        case .emerald:
            return Color.adaptive(
                light: UIColor(red: 130/255, green: 230/255, blue: 160/255, alpha: 1),
                dark: UIColor(red: 100/255, green: 180/255, blue: 120/255, alpha: 1)) // Lime-green
        }
    }

    var successColor: Color {
        switch self {
        case .default:
            return Color.adaptive(
                light: .systemGreen,
                dark: UIColor(red: 48/255, green: 209/255, blue: 88/255, alpha: 1))
        case .midnight:
            return Color.adaptive(
                light: UIColor(red: 64/255, green: 224/255, blue: 175/255, alpha: 1),
                dark: UIColor(red: 80/255, green: 255/255, blue: 200/255, alpha: 1)) // Teal
        case .sunset:
            return Color.adaptive(
                light: UIColor(red: 80/255, green: 220/255, blue: 100/255, alpha: 1),
                dark: UIColor(red: 100/255, green: 255/255, blue: 120/255, alpha: 1)) // Warm green
        case .forest:
            return Color.adaptive(
                light: UIColor(red: 50/255, green: 180/255, blue: 90/255, alpha: 1),
                dark: UIColor(red: 70/255, green: 220/255, blue: 110/255, alpha: 1)) // Forest green
        case .ocean:
            return Color.adaptive(
                light: UIColor(red: 50/255, green: 215/255, blue: 180/255, alpha: 1),
                dark: UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)) // Aqua
        case .lavender:
            return Color.adaptive(
                light: UIColor(red: 120/255, green: 210/255, blue: 160/255, alpha: 1),
                dark: UIColor(red: 140/255, green: 230/255, blue: 180/255, alpha: 1)) // Mint
        case .crimson:
            return Color.adaptive(
                light: UIColor(red: 70/255, green: 220/255, blue: 120/255, alpha: 1),
                dark: UIColor(red: 90/255, green: 255/255, blue: 140/255, alpha: 1)) // Lush green
        case .arctic:
            return Color.adaptive(
                light: UIColor(red: 48/255, green: 209/255, blue: 170/255, alpha: 1),
                dark: UIColor(red: 80/255, green: 230/255, blue: 200/255, alpha: 1)) // Icy teal
        case .amber:
            return Color.adaptive(
                light: UIColor(red: 102/255, green: 187/255, blue: 106/255, alpha: 1),
                dark: UIColor(red: 130/255, green: 210/255, blue: 130/255, alpha: 1)) // Golden green
        case .sapphire:
            return Color.adaptive(
                light: UIColor(red: 64/255, green: 224/255, blue: 175/255, alpha: 1),
                dark: UIColor(red: 90/255, green: 255/255, blue: 200/255, alpha: 1)) // Aqua-cyan
        case .emerald:
            return Color.adaptive(
                light: UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1),
                dark: UIColor(red: 52/255, green: 211/255, blue: 153/255, alpha: 1)) // Emerald
        }
    }

    var warningColor: Color {
        switch self {
        case .default:
            return Color.adaptive(
                light: UIColor(red: 230/255, green: 90/255, blue: 12/255, alpha: 1),
                dark: UIColor(red: 255/255, green: 159/255, blue: 10/255, alpha: 1))
        case .midnight:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 170/255, blue: 0/255, alpha: 1),
                dark: UIColor(red: 255/255, green: 190/255, blue: 100/255, alpha: 1)) // Golden amber
        case .sunset:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 140/255, blue: 50/255, alpha: 1),
                dark: UIColor(red: 255/255, green: 180/255, blue: 80/255, alpha: 1)) // Warm orange
        case .forest:
            return Color.adaptive(
                light: UIColor(red: 240/255, green: 170/255, blue: 40/255, alpha: 1),
                dark: UIColor(red: 250/255, green: 200/255, blue: 50/255, alpha: 1)) // Autumn amber
        case .ocean:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 165/255, blue: 50/255, alpha: 1),
                dark: UIColor(red: 255/255, green: 180/255, blue: 80/255, alpha: 1)) // Coral orange
        case .lavender:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 160/255, blue: 70/255, alpha: 1),
                dark: UIColor(red: 255/255, green: 190/255, blue: 100/255, alpha: 1)) // Peach
        case .crimson:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 140/255, blue: 40/255, alpha: 1),
                dark: UIColor(red: 255/255, green: 160/255, blue: 60/255, alpha: 1)) // Orange-red
        case .arctic:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 200/255, blue: 80/255, alpha: 1),
                dark: UIColor(red: 255/255, green: 220/255, blue: 110/255, alpha: 1)) // Soft amber
        case .amber:
            return Color.adaptive(
                light: UIColor(red: 245/255, green: 166/255, blue: 35/255, alpha: 1),
                dark: UIColor(red: 251/255, green: 192/255, blue: 45/255, alpha: 1)) // Rich amber
        case .sapphire:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 165/255, blue: 50/255, alpha: 1),
                dark: UIColor(red: 255/255, green: 180/255, blue: 77/255, alpha: 1)) // Royal gold
        case .emerald:
            return Color.adaptive(
                light: UIColor(red: 255/255, green: 200/255, blue: 40/255, alpha: 1),
                dark: UIColor(red: 255/255, green: 220/255, blue: 80/255, alpha: 1)) // Sunflower
        }
    }

    var dangerColor: Color {
        switch self {
        case .default:
            return Color.adaptive(light: .systemRed, dark: UIColor(red: 255/255, green: 69/255, blue: 58/255, alpha: 1))
        case .midnight:
            return Color.adaptive(light: UIColor(red: 255/255, green: 60/255, blue: 100/255, alpha: 1), dark: UIColor(red: 255/255, green: 100/255, blue: 130/255, alpha: 1)) // Pink-red
        case .sunset:
            return Color.adaptive(light: UIColor(red: 244/255, green: 50/255, blue: 50/255, alpha: 1), dark: UIColor(red: 255/255, green: 80/255, blue: 80/255, alpha: 1)) // Hot red
        case .forest:
            return Color.adaptive(light: UIColor(red: 220/255, green: 60/255, blue: 50/255, alpha: 1), dark: UIColor(red: 255/255, green: 80/255, blue: 70/255, alpha: 1)) // Rusty red
        case .ocean:
            return Color.adaptive(light: UIColor(red: 239/255, green: 80/255, blue: 80/255, alpha: 1), dark: UIColor(red: 255/255, green: 100/255, blue: 100/255, alpha: 1)) // Coral red
        case .lavender:
            return Color.adaptive(light: UIColor(red: 255/255, green: 80/255, blue: 100/255, alpha: 1), dark: UIColor(red: 255/255, green: 110/255, blue: 120/255, alpha: 1)) // Rose red
        case .crimson:
            return Color.adaptive(light: UIColor(red: 200/255, green: 40/255, blue: 50/255, alpha: 1), dark: UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)) // Deep crimson
        case .arctic:
            return Color.adaptive(light: UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1), dark: UIColor(red: 255/255, green: 115/255, blue: 115/255, alpha: 1)) // Cool red
        case .amber:
            return Color.adaptive(light: UIColor(red: 211/255, green: 47/255, blue: 47/255, alpha: 1), dark: UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1)) // Warm red
        case .sapphire:
            return Color.adaptive(light: UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1), dark: UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)) // Crimson
        case .emerald:
            return Color.adaptive(light: UIColor(red: 200/255, green: 50/255, blue: 50/255, alpha: 1), dark: UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)) // Red
        }
    }

    var infoColor: Color {
        switch self {
        case .default:
            return Color.adaptive(light: .systemBlue, dark: UIColor(red: 10/255, green: 132/255, blue: 255/255, alpha: 1))
        case .midnight:
            return Color.adaptive(light: UIColor(red: 100/255, green: 140/255, blue: 255/255, alpha: 1), dark: UIColor(red: 80/255, green: 120/255, blue: 255/255, alpha: 1))
        case .sunset:
            return Color.adaptive(light: UIColor(red: 100/255, green: 160/255, blue: 255/255, alpha: 1), dark: UIColor(red: 70/255, green: 130/255, blue: 255/255, alpha: 1))
        case .forest:
            return Color.adaptive(light: UIColor(red: 80/255, green: 160/255, blue: 220/255, alpha: 1), dark: UIColor(red: 50/255, green: 120/255, blue: 200/255, alpha: 1))
        case .ocean:
            return Color.adaptive(light: UIColor(red: 70/255, green: 160/255, blue: 240/255, alpha: 1), dark: UIColor(red: 50/255, green: 120/255, blue: 200/255, alpha: 1))
        case .lavender:
            return Color.adaptive(light: UIColor(red: 140/255, green: 130/255, blue: 255/255, alpha: 1), dark: UIColor(red: 120/255, green: 100/255, blue: 255/255, alpha: 1))
        case .crimson:
            return Color.adaptive(light: UIColor(red: 160/255, green: 120/255, blue: 255/255, alpha: 1), dark: UIColor(red: 120/255, green: 80/255, blue: 255/255, alpha: 1))
        case .arctic:
            return Color.adaptive(light: UIColor(red: 120/255, green: 200/255, blue: 255/255, alpha: 1), dark: UIColor(red: 80/255, green: 160/255, blue: 255/255, alpha: 1))
        case .amber:
            return Color.adaptive(light: UIColor(red: 255/255, green: 190/255, blue: 70/255, alpha: 1), dark: UIColor(red: 220/255, green: 160/255, blue: 50/255, alpha: 1))
        case .sapphire:
            return Color.adaptive(light: UIColor(red: 100/255, green: 150/255, blue: 250/255, alpha: 1), dark: UIColor(red: 60/255, green: 110/255, blue: 220/255, alpha: 1))
        case .emerald:
            return Color.adaptive(light: UIColor(red: 80/255, green: 220/255, blue: 140/255, alpha: 1), dark: UIColor(red: 50/255, green: 180/255, blue: 100/255, alpha: 1))
        }
    }
}
