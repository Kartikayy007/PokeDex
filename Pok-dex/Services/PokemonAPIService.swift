//
//  PokemonAPIService.swift
//  Pok-dex
//
//  Created by kartikay on 18/09/25.
//

import Foundation
import Combine

class PokemonAPIService: ObservableObject {
    static let shared = PokemonAPIService()
    private let baseURL = "https://pokeapi.co/api/v2"
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    func fetchPokemonList(limit: Int = 20, offset: Int = 0) async throws -> PokemonListResponse {
        guard let url = URL(string: "\(baseURL)/pokemon?limit=\(limit)&offset=\(offset)") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(PokemonListResponse.self, from: data)
    }

    func fetchPokemonDetail(id: Int) async throws -> Pokemon {
        guard let url = URL(string: "\(baseURL)/pokemon/\(id)") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Pokemon.self, from: data)
    }

    func fetchPokemonByName(_ name: String) async throws -> Pokemon {
        guard let url = URL(string: "\(baseURL)/pokemon/\(name.lowercased())") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Pokemon.self, from: data)
    }

    func fetchPokemonSpecies(id: Int) async throws -> PokemonSpecies {
        guard let url = URL(string: "\(baseURL)/pokemon-species/\(id)") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(PokemonSpecies.self, from: data)
    }

    func fetchEvolutionChain(url: String) async throws -> EvolutionChain {
        guard let url = URL(string: url) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(EvolutionChain.self, from: data)
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received"
        }
    }
}