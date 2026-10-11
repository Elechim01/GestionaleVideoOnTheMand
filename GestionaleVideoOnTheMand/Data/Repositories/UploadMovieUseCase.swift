//
//  UploadMovieUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 22/03/26.
//

import Foundation
import Services
import AppKit
import ElechimCore

final class UploadMovieUseCase: Sendable {
    private let storageRepo: StorageReposotoryProtocol
    
    init(storageRepo: StorageReposotoryProtocol) {
        self.storageRepo = storageRepo
    }
    
    func execute(idLocalUser: String,
                 nome: String,
                 file: URL,
                 size: Double,
                 onCreateThumbnail: @MainActor @escaping (NSImage) -> (),
                 onUpdate: @MainActor @escaping (UploadStatus, Double) -> ()) async throws {
        onUpdate(.createThumnail,0)
        guard let thumbnail = await UtilitiesFiles.createThumbnail(url: file) else {
            throw CustomError.fileError
        }
        onUpdate(.createThumnail,100)
        onCreateThumbnail(thumbnail)
        onUpdate(.uploadFilm,0)
        let videoResponse = try await  storageRepo.upload(file: file) { progress in
            Task { @MainActor in
                 onUpdate(.uploadFilm,progress)
            }
        }
        onUpdate(.uploadThumbnail,0)
        let fileURLThumbnail = UtilitiesFiles.createTempFile(from: thumbnail)
        let thumbnailResponse = try await storageRepo.upload(file: fileURLThumbnail) { progress in
            Task { @MainActor in
                onUpdate(.uploadThumbnail,progress)
            }
        }
        onUpdate(.addFilmToDB,0)
        let film = Film(id: UUID().uuidString,
                        idUtente: idLocalUser,
                        nome: nome,
                        url: videoResponse.completeURL,
                        thmbnail: thumbnailResponse.completeURL,
                        size: size,
                        fileName: videoResponse.fileName,
                        thumbnailName: thumbnailResponse.fileName)
        
        try await storageRepo.saveFilm(film: film)
        onUpdate(.addFilmToDB,100)
    }
    
}
