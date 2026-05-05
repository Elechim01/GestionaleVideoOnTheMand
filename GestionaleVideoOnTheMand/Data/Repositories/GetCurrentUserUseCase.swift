//
//  GetCurrentUserUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 22/03/26.
//

import Foundation
import Services

final class GetCurrentUserUseCase {
    
    private let authRepository: AuthRepositoryProtocol
    private let credentialRepository: CredentialRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol,
         credentialRepository: CredentialRepositoryProtocol) {
        self.authRepository = authRepository
        self.credentialRepository = credentialRepository
    }
    
    func execute(idUser: String) async throws -> Utente {
        return try await  authRepository.getCurrentUser(idUser: idUser)
    }
}
