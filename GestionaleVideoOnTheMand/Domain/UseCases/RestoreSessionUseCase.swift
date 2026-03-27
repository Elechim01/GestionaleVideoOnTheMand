//
//  RestoreSessionUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 24/03/26.
//

import Foundation

class RestoreSessionUseCase {
    
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute() async throws -> Bool {
        guard let _ = authRepository.currentUser() else {
            return false
        }
        
        let _ = authRepository.getSavedCredential()
        
        try await authRepository.token(username: "Michele", password: "Michele1")
        return true
    }
}
