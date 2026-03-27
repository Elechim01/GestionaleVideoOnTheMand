//
//  RegistrationUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/03/26.
//

import Foundation

final class RegistrationUseCase {

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(nome:String,
                 cognome: String,
                 email: String,
                 password: String,
                 cellulare: String) async throws -> String {
        let utente = Utente(id: "",
                            nome: nome,
                            cognome: cognome,
                            email: email,
                            password: password,
                            cellulare:cellulare)
        let id =  try await repository.createUser(user: utente)
        try await repository.saveCredential(email: email, password: password)
        return id 
    }
    
}
