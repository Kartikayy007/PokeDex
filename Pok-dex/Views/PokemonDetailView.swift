//
//  PokemonDetailView.swift
//  Pok-dex
//
//  Created by kartikay on 18/09/25.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @StateObject private var viewModel: PokemonDetailViewModel
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss

    init(pokemon: Pokemon) {
        self.pokemon = pokemon
        self._viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemon: pokemon))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: PokemonTypeColors.gradientColors(for: pokemon.primaryType),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 60)

                    pokemonImageSection

                    detailsCard
                }
            }
            .ignoresSafeArea(edges: .top)

            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button(action: { viewModel.toggleFavorite() }) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 50)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            HStack(spacing: 8) {
                ForEach(pokemon.types) { type in
                    TypeBadge(typeName: type.type.name)
                }
            }

            Text(pokemon.formattedId)
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
    }

    private var pokemonImageSection: some View {
        AsyncImage(url: URL(string: pokemon.sprites.artworkURL ?? "")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
        }
        .frame(height: 200)
        .padding()
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TabButton(title: "About", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "Base Stats", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "Evolution", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                TabButton(title: "Moves", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .padding(.top, 20)

            Group {
                switch selectedTab {
                case 0:
                    AboutTab(pokemon: pokemon, species: viewModel.pokemonSpecies)
                case 1:
                    BaseStatsTab(pokemon: pokemon)
                case 2:
                    EvolutionTab(evolutionChain: viewModel.evolutionChain)
                case 3:
                    MovesTab(moves: pokemon.moves)
                default:
                    EmptyView()
                }
            }
            .padding()
            .animation(.easeInOut, value: selectedTab)
        }
        .background(Color.white)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .shadow(radius: 10)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .black : .gray)

                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct AboutTab: View {
    let pokemon: Pokemon
    let species: PokemonSpecies?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let species = species {
                Text(species.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
            }

            InfoRow(label: "Species", value: species?.genus ?? "Seed Pokémon")
            InfoRow(label: "Height", value: pokemon.formattedHeight)
            InfoRow(label: "Weight", value: pokemon.formattedWeight)

            VStack(alignment: .leading, spacing: 8) {
                Text("Abilities")
                    .font(.system(size: 16, weight: .bold))

                ForEach(pokemon.abilities) { ability in
                    HStack {
                        Text(ability.ability.displayName)
                            .font(.system(size: 14))
                        if ability.isHidden {
                            Text("(Hidden)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            if let species = species {
                Text("Breeding")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.top, 8)

                HStack {
                    Text("Gender")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .frame(width: 100, alignment: .leading)

                    if species.genderRate == -1 {
                        Text("Genderless")
                            .font(.system(size: 14))
                    } else {
                        HStack(spacing: 8) {
                            HStack(spacing: 2) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 12))
                                Text("\(Int(species.genderRatio.male))%")
                                    .font(.system(size: 14))
                            }
                            HStack(spacing: 2) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.pink)
                                    .font(.system(size: 12))
                                Text("\(Int(species.genderRatio.female))%")
                                    .font(.system(size: 14))
                            }
                        }
                    }
                }

                InfoRow(label: "Egg Groups", value: species.eggGroups.map { $0.name.capitalized }.joined(separator: ", "))
                InfoRow(label: "Egg Cycle", value: "\(species.hatchCounter)")
            }
        }
    }
}

struct BaseStatsTab: View {
    let pokemon: Pokemon

    var body: some View {
        VStack(spacing: 16) {
            ForEach(pokemon.stats) { stat in
                StatRow(stat: stat)
            }

            HStack {
                Text("Total")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 80, alignment: .leading)

                Text("\(pokemon.stats.reduce(0) { $0 + $1.baseStat })")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 40, alignment: .center)

                Spacer()
            }
            .padding(.top, 8)

            Text("Type defenses")
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)

            Text("The effectiveness of each type on \(pokemon.name.capitalized).")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct StatRow: View {
    let stat: PokemonStat

    var statColor: Color {
        if stat.baseStat < 50 {
            return .red
        } else if stat.baseStat < 80 {
            return .orange
        } else if stat.baseStat < 120 {
            return .green
        } else {
            return .blue
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(stat.displayName)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)

            Text("\(stat.baseStat)")
                .font(.system(size: 14, weight: .medium))
                .frame(width: 40, alignment: .center)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(statColor)
                        .frame(width: geometry.size.width * stat.statProgress, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

struct EvolutionTab: View {
    let evolutionChain: EvolutionChain?

    var body: some View {
        VStack {
            if evolutionChain != nil {
                Text("Evolution Chain")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Evolution chain visualization coming soon")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Text("Loading evolution data...")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct MovesTab: View {
    let moves: [PokemonMove]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Moves (\(moves.count))")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.bottom, 8)

                ForEach(moves.prefix(20), id: \.move.name) { pokemonMove in
                    Text(pokemonMove.move.displayName)
                        .font(.system(size: 14))
                        .padding(.vertical, 4)
                }

                if moves.count > 20 {
                    Text("And \(moves.count - 20) more...")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(.system(size: 14))
        }
    }
}

struct TypeBadge: View {
    let typeName: String

    var body: some View {
        Text(typeName.capitalized)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.3))
            .cornerRadius(12)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
