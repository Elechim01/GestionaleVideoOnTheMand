//
//  Film.swift
//  VideoOnThemand
//
//  Created by Michele Manniello on 09/08/22.
//


import SwiftUI
import AppKit
import Foundation
@preconcurrency import FirebaseFirestore

struct Film: Identifiable, Codable,Sendable {
    
    @DocumentID var documentId: String?
    var id: String
    var idUtente: String
    var nome: String
    var url: String
    var thumbnail: String
    var size: Double
    var fileName: String
    var thumbnailName: String
    #warning("Read message")
    //TODO: AGGIUNGERE UNA DATA
    
    init(){
        id = ""
        idUtente = ""
        nome = ""
        url = ""
        thumbnail = ""
        size = 0
        fileName = ""
        thumbnailName = ""
    }
    
    init(id : String,
         idUtente: String,
         nome: String,
         url: String,
         thmbnail: String,
         size: Double,
         fileName: String,
         thumbnailName: String){
        self.id = id
        self.idUtente = idUtente
        self.nome = nome
        self.url = url
        self.thumbnail = thmbnail
        self.size = size
        self.fileName = fileName
        self.thumbnailName = thumbnailName
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
    .init(id: "1", idUtente: "", nome: "OnePiece_Ep_1069_SUB_ITA.mp4", url: "", thmbnail: "http://192.168.1.119:3000/media/1765792379878-thumbnail.png", size: 30, fileName: "", thumbnailName: ""),
    .init(id: "2", idUtente: "", nome: "OnePiece_Ep_1069_SUB_ITA.mp4", url: "", thmbnail: "http://192.168.1.119:3000/media/1765792379878-thumbnail.png", size: 30, fileName: "", thumbnailName: ""),
    .init(id: "3", idUtente: "", nome: "OnePiece_Ep_1069_SUB_ITA.mp4", url: "", thmbnail: "http://192.168.1.119:3000/media/1765792379878-thumbnail.png", size: 30, fileName: "", thumbnailName: ""),
    .init(id: "4", idUtente: "", nome: "OnePiece_Ep_1069_SUB_ITA.mp4", url: "", thmbnail: "http://192.168.1.119:3000/media/1765792379878-thumbnail.png", size: 30, fileName: "", thumbnailName: ""),
    .init(id: "5", idUtente: "", nome: "OnePiece_Ep_1069_SUB_ITA.mp4", url: "", thmbnail: "http://192.168.1.119:3000/media/1765792379878-thumbnail.png", size: 30, fileName: "", thumbnailName: ""),
    
    
    
]
