//
//  SessionManager.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 21/04/26.
//

import SwiftUI
import Services

final class SessionManager: ObservableObject {
    @Published var currentUser: Utente?
    @AppStorage("IDUser") private var storeUserID: String = ""
    
    var idUser: String {
        storeUserID
    }
    
    func saveSession(id: String) {
        self.storeUserID = id
    }
    
    func clearSession() {
        currentUser = nil
        storeUserID = ""
    }
}
