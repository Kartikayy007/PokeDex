//
//  PokemonListView.swift
//  Pok-dex
//
//  Created by kartikay on 18/09/25.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonListViewModel()
    @State private var selectedPokemon: Pokemon?
    @State private var showingDetail = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pokemonBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        searchBar

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.filteredPokemonList) { pokemon in
                                PokemonCardView(pokemon: pokemon)
                                    .onTapGesture {
                                        selectedPokemon = pokemon
                                        showingDetail = true
                                    }
                                    .onAppear {
                                        viewModel.loadMorePokemonIfNeeded(currentItem: pokemon)
                                    }
                            }
                        }
                        .padding(.horizontal, 16)

                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationTitle("Pokédex")
            .navigationBarTitleDisplayMode(.inline)

            .navigationDestination(isPresented: $showingDetail) {
                if let pokemon = selectedPokemon {
                    PokemonDetailView(pokemon: pokemon)
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search Pokémon", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

#Preview {
    PokemonListView()
}
