//
//  PokemonDetailViewModel.swift
//  Pok-dex
//
//  Created by kartikay on 18/09/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PokemonDetailViewModel: ObservableObject {
    @Published var pokemon: Pokemon?
    @Published var pokemonSpecies: PokemonSpecies?
    @Published var evolutionChain: EvolutionChain?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isFavorite = false

    private let apiService = PokemonAPIService.shared

    init(pokemon: Pokemon? = nil) {
        self.pokemon = pokemon
        if let pokemon = pokemon {
            loadPokemonDetails(for: pokemon.id)
        }
    }

    func loadPokemonDetails(for id: Int) {
        Task {
            await fetchPokemonDetails(id: id)
        }
    }

    func fetchPokemonDetails(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch Pokemon if not already loaded
            if pokemon == nil || pokemon?.id != id {
                pokemon = try await apiService.fetchPokemonDetail(id: id)
            }

            // Fetch species information
            pokemonSpecies = try await apiService.fetchPokemonSpecies(id: id)

            // Fetch evolution chain
            if let evolutionURL = pokemonSpecies?.evolutionChain.url {
                evolutionChain = try await apiService.fetchEvolutionChain(url: evolutionURL)
            }

            checkIfFavorite()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleFavorite() {
        isFavorite.toggle()
        saveFavoriteStatus()
    }

    private func checkIfFavorite() {
        guard let pokemonId = pokemon?.id else { return }
        let favorites = UserDefaults.standard.array(forKey: "favoritePokemon") as? [Int] ?? []
        isFavorite = favorites.contains(pokemonId)
    }

    private func saveFavoriteStatus() {
        guard let pokemonId = pokemon?.id else { return }
        var favorites = UserDefaults.standard.array(forKey: "favoritePokemon") as? [Int] ?? []

        if isFavorite {
            if !favorites.contains(pokemonId) {
                favorites.append(pokemonId)
            }
        } else {
            favorites.removeAll { $0 == pokemonId }
        }

        UserDefaults.standard.set(favorites, forKey: "favoritePokemon")
    }
}