//
//  Enum.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 01/01/23.
//

import Foundation

enum Page: Int, Equatable {
    case Login = 0
    case Registration = 1
    case Home = 2
}



enum HomeSection {
    case film
    case spazio
}

enum UploadStatus: String {
    case cancel = "Cancellato"
    case uploadFilm = "Carico il Film"
    case addFilmToDB = "Carico il film a db"
    case createThumnail = "Creo la thumbnail"
    case uploadThumbnail = "Carico la thumbnail"
    case succes = "Completato con successo"
    case error = "Errore nel caricamento"
    case loadFilm = "Carica Film"
}
