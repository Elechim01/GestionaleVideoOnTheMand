//
//  AuthRepository.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 22/03/26.
//

import Foundation
import Services
import FirebaseAuth
import ElechimCore

final class AuthRepository: AuthRepositoryProtocol {
    
    func signIn(email: String, password: String) async throws -> String {
        let authResult = try await FirebaseUtils.shared.signIn(email: email, password: password)
        return authResult.user.uid
    }
    
    func token(username: String, password: String) async throws {
        try await TokenRequest(tokenBody: TokenBodyRequest(username: username, password: password)).performRequestAsync()
    }
    
    func getCurrentUser(idUser: String) async throws -> Utente {
        guard  let user: Utente = try await FirebaseUtils.shared.recuperoUtente(id: idUser) else {
            throw CustomError.noUser
        }
        return user
    }
    
    func currentUser() -> User? {
        Auth.auth().currentUser
    }
    
    func logOut() throws {
        let firebase = Auth.auth()
        try firebase.signOut()
        AuthKeyChain.shared.delete()
    }
    
    func createUser(user: Utente, email: String, password: String) async throws -> String {
        let id =  try await FirebaseUtils.shared.createUser(email: email,
                                                            password: password)
        var copyUser = user
        copyUser.id = id
        
        do {
            try await FirebaseUtils.shared.addUtente(utente: copyUser)
        } catch  {
            try? await FirebaseUtils.shared.deleteUser()
            throw error
        }
        return id
    }
    
    func restorePassword(email: String) async throws {
        try await FirebaseUtils.shared.restorePassword(email: email)
    }
    
}

class AuthRepositoryMock: AuthRepositoryProtocol {
    func restorePassword(email: String) async throws {
        
    }
    
    func getCurrentUser(idUser: String) async throws -> Utente {
        Utente(id: "",
               nome: "",
               cognome: "",
               cellulare: "")
    }
    
    func signIn(email: String, password: String)  async throws -> String {
        ""
    }
    
    func token(username: String, password: String)async throws {
        
    }
    
    func currentUser() -> User? {
        nil
    }
    
    
    func logOut() throws {
        
    }
    func createUser(user: Utente, email: String, password: String) async throws -> String {
        ""
    }
}
