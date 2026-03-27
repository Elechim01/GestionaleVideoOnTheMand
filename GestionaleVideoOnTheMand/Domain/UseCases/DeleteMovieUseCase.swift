//
//  DeleteMovieUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 21/03/26.
//

import Foundation
import Services
import ElechimCore

class DeleteMovieUseCase {
    let repository: MovieRepositoryProtocol
    
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(film: Film) async throws {
        guard let documentId = film.documentId else {
            throw CustomError.errorFilm
        }
        try await repository.deleteMovie(
            fileName: film.fileName,
            thumbnailName: film.thumbnailName,
            docId: documentId)
    }
}
