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
         try await DeleteRequest(fileName: fileName).performAsync()
         try await DeleteRequest(fileName: thumbnailName).performAsync()
         try await  FirebaseUtils.shared.removeDocument(filmId: docId)
        
    }
    
}
