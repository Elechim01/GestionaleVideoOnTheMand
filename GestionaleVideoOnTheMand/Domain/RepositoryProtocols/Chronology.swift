//
//  Chronology.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/04/26.
//

import Foundation


struct Chronology: Identifiable, Codable {
    var id: String = UUID().uuidString
    var date: Date
    var filmName: String
    var idFilm: String
    var localUserId:String
    
    
    init(film: Film, localUsedId: String) {
        self.date = .now
        self.filmName = film.nome
        self.idFilm = film.id
        self.localUserId = localUsedId
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case filmName
        case idFilm
        case localUserId = "idUtente"
    }
    
}
