//
//  RegistrationUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/03/26.
//

import Foundation
import Services

final class RegistrationUseCase {

    private let authRepository: AuthRepositoryProtocol
    private let credentialRepository: CredentialRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol,
         credentialRepository: CredentialRepositoryProtocol) {
        self.authRepository = authRepository
        self.credentialRepository = credentialRepository
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
        let id =  try await authRepository.createUser(user: utente)
        try credentialRepository.saveCredential(email: email, password: password)
        return id
    }
    
}
