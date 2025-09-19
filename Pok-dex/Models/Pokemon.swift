//
//  Pokemon.swift
//  Pok-dex
//
//  Created by kartikay on 18/09/25.
//

import Foundation

struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
}

struct PokemonListItem: Codable, Identifiable {
    let name: String
    let url: String

    var id: Int {
        return Int(url.split(separator: "/").last ?? "0") ?? 0
    }
}

struct Pokemon: Codable, Identifiable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let baseExperience: Int?
    let sprites: Sprites
    let stats: [PokemonStat]
    let types: [PokemonType]
    let abilities: [PokemonAbility]
    let moves: [PokemonMove]
    let species: Species

    var formattedId: String {
        return String(format: "#%03d", id)
    }

    var formattedHeight: String {
        let meters = Double(height) / 10
        let feet = meters * 3.28084
        return String(format: "%.1f m (%.1f ft)", meters, feet)
    }

    var formattedWeight: String {
        let kg = Double(weight) / 10
        let lbs = kg * 2.20462
        return String(format: "%.1f kg (%.1f lbs)", kg, lbs)
    }

    var primaryType: String {
        return types.first?.type.name.capitalized ?? "Unknown"
    }

    var typeColor: String {
        return PokemonTypeColors.color(for: primaryType.lowercased())
    }
}

struct Sprites: Codable {
    let frontDefault: String?
    let frontShiny: String?
    let backDefault: String?
    let backShiny: String?
    let other: OtherSprites?

    var artworkURL: String? {
        return other?.officialArtwork?.frontDefault ?? frontDefault
    }
}

struct OtherSprites: Codable {
    let officialArtwork: OfficialArtwork?

    private enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Codable {
    let frontDefault: String?
    let frontShiny: String?
}

struct PokemonStat: Codable, Identifiable {
    let baseStat: Int
    let effort: Int
    let stat: Stat

    var id: String {
        return stat.name
    }

    var displayName: String {
        switch stat.name {
        case "hp": return "HP"
        case "attack": return "Attack"
        case "defense": return "Defense"
        case "special-attack": return "Sp. Atk"
        case "special-defense": return "Sp. Def"
        case "speed": return "Speed"
        default: return stat.name.capitalized
        }
    }

    var statProgress: Double {
        return Double(baseStat) / 255.0
    }
}

struct Stat: Codable {
    let name: String
    let url: String
}

struct PokemonType: Codable, Identifiable {
    let slot: Int
    let type: TypeDetail

    var id: String {
        return type.name
    }
}

struct TypeDetail: Codable {
    let name: String
    let url: String
}

struct PokemonAbility: Codable, Identifiable {
    let isHidden: Bool
    let slot: Int
    let ability: Ability

    var id: String {
        return ability.name
    }
}

struct Ability: Codable {
    let name: String
    let url: String

    var displayName: String {
        return name.split(separator: "-").map { $0.capitalized }.joined(separator: " ")
    }
}

struct PokemonMove: Codable {
    let move: Move
}

struct Move: Codable {
    let name: String
    let url: String

    var displayName: String {
        return name.split(separator: "-").map { $0.capitalized }.joined(separator: " ")
    }
}

struct Species: Codable {
    let name: String
    let url: String
}

struct PokemonSpecies: Codable {
    let id: Int
    let name: String
    let evolutionChain: EvolutionChainInfo
    let flavorTextEntries: [FlavorText]
    let genera: [Genus]
    let genderRate: Int
    let eggGroups: [NamedResource]
    let hatchCounter: Int
    let growthRate: NamedResource

    var description: String {
        return flavorTextEntries.first(where: { $0.language.name == "en" })?.flavorText
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "", with: " ") ?? ""
    }

    var genus: String {
        return genera.first(where: { $0.language.name == "en" })?.genus ?? "Pokémon"
    }

    var genderRatio: (male: Double, female: Double) {
        if genderRate == -1 {
            return (male: 0, female: 0)
        }
        let femaleRate = Double(genderRate) * 12.5
        let maleRate = 100.0 - femaleRate
        return (male: maleRate, female: femaleRate)
    }
}

struct EvolutionChainInfo: Codable {
    let url: String
}

struct FlavorText: Codable {
    let flavorText: String
    let language: NamedResource
}

struct Genus: Codable {
    let genus: String
    let language: NamedResource
}

struct NamedResource: Codable {
    let name: String
    let url: String
}

struct EvolutionChain: Codable {
    let id: Int
    let chain: ChainLink
}

struct ChainLink: Codable {
    let species: NamedResource
    let evolvesTo: [ChainLink]
    let evolutionDetails: [EvolutionDetail]
}

struct EvolutionDetail: Codable {
    let minLevel: Int?
    let trigger: NamedResource
}
