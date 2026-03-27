//
//  MovieRepository.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 21/03/26.
//

import Foundation
import Services

class MovieRepository: MovieRepositoryProtocol {
    func loadFilm(localUserId: String)  async throws -> AsyncStream<[Film]>  {
       return  await  FirebaseUtils.shared.recuperoFilm(localUserId: localUserId)
    }
    
    
    func deleteMovie(fileName: String,thumbnailName: String, docId: String) async throws {
        let _ = try await DeleteRequest(fileName: fileName).performAsync()
        let _ = try await DeleteRequest(fileName: thumbnailName).performAsync()
        let _ = try await  FirebaseUtils.shared.removeDocument(filmId: docId)
        
    }
    
}
