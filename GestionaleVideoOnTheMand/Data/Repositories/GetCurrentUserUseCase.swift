//
//  GetCurrentUserUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 22/03/26.
//

import Foundation

class GetCurrentUserUseCase {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute(idUser: String) async throws -> Utente {
       
        return try await  authRepository.getCurrentUser(idUser: idUser)
    }
}
