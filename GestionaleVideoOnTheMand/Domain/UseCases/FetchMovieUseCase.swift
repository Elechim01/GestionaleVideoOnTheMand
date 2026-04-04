//
//  FetchMovieUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 22/03/26.
//

import Foundation

final class FetchMovieUseCase {
    private let movieRepository: MovieRepositoryProtocol
   
    init(movieRepository: MovieRepositoryProtocol) {
        self.movieRepository = movieRepository
    }
    
    func execute(localUserId: String) async -> AsyncThrowingStream<[Film],Error> {
        return  await movieRepository.loadFilm(localUserId: localUserId)
    }
    
}
