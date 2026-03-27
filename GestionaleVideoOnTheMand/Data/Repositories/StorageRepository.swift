//
//  StorageRepository.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 22/03/26.
//

import Foundation
import Services
import ElechimCore

class StorageRepository: StorageReposotoryProtocol {
    func upload(file: URL, onProgress: @escaping (Double) -> Void) async throws -> UploadFilmResponse {
        for await  update in await UploadFilmRequest(file: file).uploadFilmAsync() {
            if let progress = update.progress {
                onProgress(progress)
            }
            if let response = update.response {
                return response
            }
            if let error = update.error {
                throw error
            }
        }
        throw CustomError.genericError
    }
    
    func saveFilm(film: Film) async throws {
        try await FirebaseUtils.shared.addFilm(film: film)
    }
}

class MockStorageRepository: StorageReposotoryProtocol {
    func upload(file: URL, onProgress: @escaping (Double) -> Void) async throws -> Services.UploadFilmResponse {
        throw CustomError.genericError
    }
    
    func saveFilm(film: Film) async throws {
        
    }
    
    
}
