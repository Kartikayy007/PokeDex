//
//  PokemonListViewModel.swift
//  Pok-dex
//
//  Created by kartikay on 18/09/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PokemonListViewModel: ObservableObject {
    @Published var pokemonList: [PokemonListItem] = []
    @Published var detailedPokemonList: [Pokemon] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    private let apiService = PokemonAPIService.shared
    private var currentOffset = 0
    private let limit = 20
    private var hasMorePokemon = true
    private var loadingTask: Task<Void, Never>?

    var filteredPokemonList: [Pokemon] {
        if searchText.isEmpty {
            return detailedPokemonList
        } else {
            return detailedPokemonList.filter { pokemon in
                pokemon.name.localizedCaseInsensitiveContains(searchText) ||
                pokemon.formattedId.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    init() {
        Task {
            await loadInitialPokemon()
        }
    }

    func loadInitialPokemon() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.fetchPokemonList(limit: limit, offset: 0)
            pokemonList = response.results
            currentOffset = limit

            // Load detailed information for each Pokemon
            await loadDetailedPokemon(for: response.results)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMorePokemonIfNeeded(currentItem: Pokemon) {
        guard let lastItem = detailedPokemonList.last else { return }

        if currentItem.id == lastItem.id && hasMorePokemon && !isLoading {
            Task {
                await loadMorePokemon()
            }
        }
    }

    func loadMorePokemon() async {
        guard !isLoading && hasMorePokemon else { return }

        isLoading = true

        do {
            let response = try await apiService.fetchPokemonList(limit: limit, offset: currentOffset)

            if response.results.isEmpty {
                hasMorePokemon = false
            } else {
                pokemonList.append(contentsOf: response.results)
                currentOffset += limit

                // Load detailed information for new Pokemon
                await loadDetailedPokemon(for: response.results)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func loadDetailedPokemon(for items: [PokemonListItem]) async {
        await withTaskGroup(of: Pokemon?.self) { group in
            for item in items {
                group.addTask { [weak self] in
                    do {
                        return try await self?.apiService.fetchPokemonDetail(id: item.id)
                    } catch {
                        print("Error loading Pokemon \(item.name): \(error)")
                        return nil
                    }
                }
            }

            for await pokemon in group {
                if let pokemon = pokemon {
                    if !self.detailedPokemonList.contains(where: { $0.id == pokemon.id }) {
                        self.detailedPokemonList.append(pokemon)
                    }
                }
            }
        }

        // Sort by ID to maintain order
        detailedPokemonList.sort { $0.id < $1.id }
    }

    func refresh() async {
        detailedPokemonList.removeAll()
        pokemonList.removeAll()
        currentOffset = 0
        hasMorePokemon = true
        await loadInitialPokemon()
    }
}