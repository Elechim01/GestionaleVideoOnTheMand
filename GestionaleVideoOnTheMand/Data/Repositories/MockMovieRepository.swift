//
//  MockMovieRepository.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 21/03/26.
//

import Foundation

class MockMovieRepository: MovieRepositoryProtocol {
    func loadFilm(localUserId: String) async throws -> AsyncStream<[Film]> {
        return AsyncStream { _ in
            
        }
    }
    
    func deleteMovie(fileName: String, thumbnailName: String, docId: String) async throws {
        print("Mock: finto delete eseguito con successo")
    }
    
    // Se avessi una fetch, restituiresti un array di film finti
}
