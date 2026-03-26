//
//  StorageReposotoryProtocol.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 22/03/26.
//

import Foundation
import Services
import AppKit

protocol StorageReposotoryProtocol {
    func upload(file: URL, onProgress: @escaping (Double) -> Void) async throws -> UploadFilmResponse
    
    func saveFilm(film: Film) async throws
    
}
