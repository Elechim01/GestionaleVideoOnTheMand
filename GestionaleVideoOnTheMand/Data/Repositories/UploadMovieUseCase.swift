//
//  UploadMovieUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 22/03/26.
//

import Foundation
import Services
import AppKit

// NOTA: CustomError, Film e UploadStatus ora sono nel Domain,
class UploadMovieUseCase {
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
        await onUpdate(.createThumnail,0)
        #warning("sostituire questo con un thumbnail -> data")
        guard let thumbnail = await Utils.createThumbnail(url: file) else {
            throw CustomError.fileError
        }
        await onUpdate(.createThumnail,100)
        await onCreateThumbnail(thumbnail)
        await onUpdate(.uploadFilm,0)
        let videoResponse = try await  storageRepo.upload(file: file) { progress in
            Task { @MainActor in
                 onUpdate(.uploadFilm,progress)
            }
        }
        await onUpdate(.uploadThumbnail,0)
        let fileURLThumbnail = FileHelper.createTempFile(from: thumbnail)
        let thumbnailResponse = try await storageRepo.upload(file: fileURLThumbnail) { progress in
            Task { @MainActor in
                onUpdate(.uploadThumbnail,progress)
            }
        }
       await onUpdate(.addFilmToDB,0)
        let film = Film(id: UUID().uuidString,
                        idUtente: idLocalUser,
                        nome: nome,
                        url: videoResponse.completeURL,
                        thmbnail: thumbnailResponse.completeURL,
                        size: size,
                        fileName: videoResponse.fileName,
                        thumbnailName: thumbnailResponse.fileName)
        
        try await storageRepo.saveFilm(film: film)
        await onUpdate(.addFilmToDB,100)
    }
    
}
