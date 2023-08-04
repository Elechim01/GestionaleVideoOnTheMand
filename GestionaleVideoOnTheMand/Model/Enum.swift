//
//  Enum.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 01/01/23.
//

import Foundation

enum Page: Int{
    case Login = 0
    case Registration = 1
    case Home = 2
}

enum CustomError: Error {
    case genericError
    case fileError
    case connectionError
   public var description: String {
       switch self {
       case .genericError:
           return "Generic Error"
       case .fileError:
           return "File Error"
       case .connectionError:
           return "Il dispositivo non è conneso a internet"
           
       }
    }
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
}
