//
//  RestoreSessionUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 24/03/26.
//

import Foundation

final class RestoreSessionUseCase {
    
    private let authRepository: AuthRepositoryProtocol
    private let credentialRepository: CredentialRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol,
         credentialRepository: CredentialRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.credentialRepository = credentialRepository
    }
    
    func execute() async throws -> Bool {
        guard let _ = authRepository.currentUser() else {
            return false
        }
        
        let _ = try credentialRepository.readCredential()
        
        try await authRepository.token(username: "Michele", password: "Michele1")
        return true
    }
}
