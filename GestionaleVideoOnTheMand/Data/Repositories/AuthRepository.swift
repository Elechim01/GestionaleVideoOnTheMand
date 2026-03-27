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

class AuthRepository: AuthRepositoryProtocol {
   
    func signIn(email: String, password: String) async throws -> String {
        let authResult = try await FirebaseUtils.shared.signIn(email: email, password: password)
        
      
        
        return authResult.user.uid
    }
    
    func saveCredential(email: String, password: String) async throws {
        AuthKeyChain.shared.setCredential(email: email, password: password)
    }
    
    
    func token(username: String, password: String) async throws {
        try await TokenRequest(tokenBody: TokenBodyRequest(username: username, password: password)).performRequestAsync()
    }
    
    func getCurrentUser(idUser: String) async throws -> Utente {
        let credential = AuthKeyChain.shared.redCredential()
        guard let email = credential.email,
              let password = credential.password else {
            // TODO: CHANGE ERROR TYPE
            throw CustomError.noCredential
        }
        
        guard  let user: Utente = try await FirebaseUtils.shared.recuperoUtente(email: email, password: password, id: idUser) else {
            throw CustomError.noUser
        }
        return user
    }
    
    func currentUser() -> User? {
        Auth.auth().currentUser
    }
    
    func getSavedCredential() -> (email: String?, password: String?) {
        let credential = AuthKeyChain.shared.redCredential()
        guard let email = credential.email,
              let password = credential.password else {
            // TODO: CHANGE ERROR TYPE
            return (nil,nil)
        }
        return(email,password)
    }
    
    func logOut() throws {
        let firebase = Auth.auth()
        try firebase.signOut()
        AuthKeyChain.shared.delete()
    }
    
    func createUser(user: Utente) async throws -> String {
        let id =  try await FirebaseUtils.shared.createUser(email: user.email,
                                                            password: user.password)
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
}

class AuthRepositoryMock: AuthRepositoryProtocol {
    func signIn(email: String, password: String)  async throws -> String {
       ""
    }
    
    func token(username: String, password: String)async throws {
        
    }
    
    func saveCredential(email: String, password: String) async throws {
        
    }
    
    func getCurrentUser(idUser: String) async throws -> Utente {
        Utente(id: "",
               nome: "",
               cognome: "",
               email: "",
               password: "",
               cellulare: "")
    }
    func currentUser() -> User? {
        nil
    }
    func getSavedCredential() -> (email: String?, password: String?) {
        ("","")
    }
    
    func logOut() throws {
        
    }
    func createUser(user: Utente) async throws -> String {
        ""
    }
}
