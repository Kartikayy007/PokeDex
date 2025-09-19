//
//  PokemonTypeColors.swift
//  Pok-dex
//
//  Created by kartikay on 18/09/25.
//

import SwiftUI

struct PokemonTypeColors {
    static func color(for type: String) -> String {
        switch type.lowercased() {
        case "normal":
            return "#A8A878"
        case "fire":
            return "#F08030"
        case "water":
            return "#6890F0"
        case "electric":
            return "#F8D030"
        case "grass":
            return "#78C850"
        case "ice":
            return "#98D8D8"
        case "fighting":
            return "#C03028"
        case "poison":
            return "#A040A0"
        case "ground":
            return "#E0C068"
        case "flying":
            return "#A890F0"
        case "psychic":
            return "#F85888"
        case "bug":
            return "#A8B820"
        case "rock":
            return "#B8A038"
        case "ghost":
            return "#705898"
        case "dragon":
            return "#7038F8"
        case "dark":
            return "#705848"
        case "steel":
            return "#B8B8D0"
        case "fairy":
            return "#EE99AC"
        default:
            return "#68A090"
        }
    }

    static func swiftUIColor(for type: String) -> Color {
        let hex = color(for: type)
        return Color(hex: hex) ?? Color.gray
    }

    static func gradientColors(for type: String) -> [Color] {
        let baseColor = swiftUIColor(for: type)
        return [
            baseColor.opacity(0.8),
            baseColor,
            baseColor.opacity(0.6)
        ]
    }
}