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
    var fileName: String
    var thumbnailName: String
    
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
    /*
    .init(id: "1", idUtente: "", nome: "OnePiece_Ep_1069_SUB_ITA.mp4", url: "", thmbnail: "", size: 45.34),
    .init(id: "2", idUtente: "", nome: "OnePiece_Ep_1069_SUB_ITA.mp4", url: "", thmbnail: "", size: 49.34),
    .init(id: "3", idUtente: "", nome: "ShuumatsuNoHarem_Ep_01_SUB_ITA.mp4", url: "", thmbnail: "", size: 45.34),
    .init(id: "4", idUtente: "", nome: "ShuumatsuNoHarem_Ep_02_SUB_ITA.mp4", url: "", thmbnail: "", size: 49.34),
    .init(id: "5", idUtente: "", nome: "ShuumatsuNoHarem_Ep_03_SUB_ITA.mp4", url: "", thmbnail: "", size: 40.34),
    .init(id: "6", idUtente: "", nome: "ShuumatsuNoHarem_Ep_04_SUB_ITA.mp4", url: "", thmbnail: "", size: 45.34),
    .init(id: "7", idUtente: "", nome: "ShuumatsuNoHarem_Ep_05_SUB_ITA.mp4", url: "", thmbnail: "", size: 49.34),
    .init(id: "8", idUtente: "", nome: "ShuumatsuNoHarem_Ep_06_SUB_ITA.mp4", url: "", thmbnail: "", size: 200),
    .init(id: "9", idUtente: "", nome: "ShuumatsuNoHarem_Ep_07_SUB_ITA.mp4", url: "", thmbnail: "", size: 200),
    .init(id: "10", idUtente: "", nome: "ShuumatsuNoHarem_Ep_08_SUB_ITA.mp4", url: "", thmbnail: "", size: 200),
    .init(id: "11", idUtente: "", nome: "ShuumatsuNoHarem_Ep_09_SUB_ITA.mp4", url: "", thmbnail: "", size: 500),
    .init(id: "12", idUtente: "", nome: "ShuumatsuNoHarem_Ep_10_SUB_ITA.mp4", url: "", thmbnail: "", size: 500),
    .init(id: "13", idUtente: "", nome: "ShuumatsuNoHarem_Ep_11_SUB_ITA.mp4", url: "", thmbnail: "", size: 500),
    */
]
