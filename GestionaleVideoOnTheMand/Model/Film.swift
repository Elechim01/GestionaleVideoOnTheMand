//
//  Film.swift
//  VideoOnThemand
//
//  Created by Michele Manniello on 09/08/22.
//


import SwiftUI
import AppKit
import Foundation

struct Film: Identifiable, Codable {
    
    //  MARK:  ID Recuperato da query firebase
    var id: String
    var idUtente: String
    var nome: String
    var url: String
    var thumbnail: String
    var size: Double
    
    init(){
        id = ""
        idUtente = ""
        nome = ""
        url = ""
        thumbnail = ""
        size = 0
    }
    
    init(id : String,
         idUtente: String,
         nome: String,
         url: String,
         thmbnail: String,
         size: Double){
        self.id = id
        self.idUtente = idUtente
        self.nome = nome
        self.url = url
        self.thumbnail = thmbnail
        self.size = size
    }
    
    func getData() -> [String:Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
            return json
        } catch  {
            return nil
        }
    }
    
    static func getFilm(json: [String: Any]) -> Film? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json)
            let film = try JSONDecoder().decode(Self.self, from: data)
            return film
        } catch  {
            return nil
        }
    }
    
}

var filmsPreview: [Film] = [
    .init(id: "", idUtente: "", nome: "Prova1", url: "", thmbnail: "", size: 45.34),
    .init(id: "", idUtente: "", nome: "Prova2", url: "", thmbnail: "", size: 49.34),
    .init(id: "", idUtente: "", nome: "Prova3", url: "", thmbnail: "", size: 45.34),
    .init(id: "", idUtente: "", nome: "Prova4", url: "", thmbnail: "", size: 49.34),
    .init(id: "", idUtente: "", nome: "Prova5", url: "", thmbnail: "", size: 40.34),
    .init(id: "", idUtente: "", nome: "Prova6", url: "", thmbnail: "", size: 45.34),
    .init(id: "", idUtente: "", nome: "Prova7", url: "", thmbnail: "", size: 49.34),
    .init(id: "", idUtente: "", nome: "Prova8", url: "", thmbnail: "", size: 200),
    .init(id: "", idUtente: "", nome: "Prova9", url: "", thmbnail: "", size: 200),
    .init(id: "", idUtente: "", nome: "Prova10", url: "", thmbnail: "", size: 200),
    .init(id: "", idUtente: "", nome: "Prova8", url: "", thmbnail: "", size: 500),
    .init(id: "", idUtente: "", nome: "Prova9", url: "", thmbnail: "", size: 500),
    .init(id: "", idUtente: "", nome: "Prova10", url: "", thmbnail: "", size: 500),
    
]
