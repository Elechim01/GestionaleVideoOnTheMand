//
//  MovieRepositoryProtocol.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 21/03/26.
//

import Foundation
import Services

protocol MovieRepositoryProtocol: Sendable {
    func deleteMovie(fileName: String,thumbnailName: String, docId: String) async throws
    func loadFilm(localUserId: String) async  -> AsyncThrowingStream<[Film],Error>
}
