//
//  Utenti.swift
//  VideoOnThemand
//
//  Created by Michele Manniello on 09/08/22.
//

import SwiftUI
import AppKit

struct Utente: Identifiable, Codable {
//   MARK: Id preso da frebase 
    var id: String
    var nome: String
    var cognome: String
    var email: String
    var password: String
    var cellulare: String
    
    var isEmply: Bool{
        if(id == "" && nome == "" && cognome == "" && email == "" && password == "" && cellulare == ""){
            return true
        }else{
            return false
        }
    }
    
    init(id: String,
         nome:String,
         cognome: String,
         email: String,
         password: String,
         cellulare: String){
        
        self.id = id
        self.nome = nome
        self.cognome = cognome
        self.email = email
        self.password = password
        self.cellulare = cellulare
    }
    
    func getData() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return json
        } catch  {
            return nil
        }
    }
    
    static func getUser(json: [String: Any]) -> Utente? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json)
            let user = try JSONDecoder().decode(Self.self, from: data)
            return user
        } catch  {
            return nil
        }
    }
    
}

var previewUser = Utente(id: "", nome: "Pippo", cognome: "Pluto", email: "paperino@outlook.it", password: "plutone", cellulare: "23456788")


