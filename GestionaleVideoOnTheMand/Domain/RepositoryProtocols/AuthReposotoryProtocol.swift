//
//  AuthRepositoryProtocol.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 22/03/26.
//

import Foundation
import Services
import FirebaseAuth

protocol AuthRepositoryProtocol {
    func getCurrentUser(idUser: String) async throws -> Utente
    func signIn(email: String, password: String) async throws ->  String
    func token(username: String, password: String) async throws
    func currentUser() -> User?
    func getSavedCredential() -> (email: String?, password: String?)
    func logOut() throws
    func createUser(user: Utente) async throws -> String
    func saveCredential(email: String, password: String) async throws 
    
}
