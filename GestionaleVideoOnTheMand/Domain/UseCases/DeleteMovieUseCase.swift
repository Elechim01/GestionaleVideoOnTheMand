//
//  DeleteMovieUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 21/03/26.
//

import Foundation
import Services

class DeleteMovieUseCase {
    let repository: MovieRepositoryProtocol
    
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(film: Film) async throws {
        guard let documentId = film.documentId else { throw CustomError.genericError }
        try await repository.deleteMovie(
            fileName: film.fileName,
            thumbnailName: film.thumbnailName,
            docId: documentId)
    }
}
