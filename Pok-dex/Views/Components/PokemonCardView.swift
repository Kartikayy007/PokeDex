//
//  PokemonCardView.swift
//  Pok-dex
//
//  Created by kartikay on 18/09/25.
//

import SwiftUI

struct PokemonCardView: View {
    let pokemon: Pokemon

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [
                        PokemonTypeColors.swiftUIColor(for: pokemon.primaryType).opacity(0.85),
                        PokemonTypeColors.swiftUIColor(for: pokemon.primaryType)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            GeometryReader { geometry in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .offset(x: geometry.size.width * 0.5, y: -geometry.size.height * 0.1)

                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                    .offset(x: -geometry.size.width * 0.2, y: geometry.size.height * 0.6)
            }
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pokemon.name.capitalized)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(pokemon.types.prefix(2)) { type in
                                Text(type.type.name.capitalized)
                                    .font(.system(size: 10, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.white.opacity(0.25))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                        }
                    }

                    Spacer(minLength: 4)

                    Text(pokemon.formattedId)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)

                Spacer(minLength: 0)

                HStack {
                    Spacer()
                    AsyncImage(url: URL(string: pokemon.sprites.artworkURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    .frame(maxWidth: 80, maxHeight: 80)
                }
                .padding(.trailing, 5)
                .padding(.bottom, 5)
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .shadow(color: PokemonTypeColors.swiftUIColor(for: pokemon.primaryType).opacity(0.3),
                radius: 5, x: 0, y: 3)
    }
}

#Preview {
    let samplePokemon = Pokemon(
        id: 25,
        name: "pikachu",
        height: 4,
        weight: 60,
        baseExperience: 112,
        sprites: Sprites(
            frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
            frontShiny: nil,
            backDefault: nil,
            backShiny: nil,
            other: OtherSprites(
                officialArtwork: OfficialArtwork(
                    frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png",
                    frontShiny: nil
                )
            )
        ),
        stats: [
            PokemonStat(
                baseStat: 35,
                effort: 0,
                stat: Stat(name: "hp", url: "")
            ),
            PokemonStat(
                baseStat: 55,
                effort: 0,
                stat: Stat(name: "attack", url: "")
            )
        ],
        types: [
            PokemonType(
                slot: 1,
                type: TypeDetail(name: "electric", url: "")
            )
        ],
        abilities: [],
        moves: [],
        species: Species(name: "pikachu", url: "")
    )

    PokemonCardView(pokemon: samplePokemon)
        .frame(width: 180, height: 180)
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Pikachu Card")
}
