//
//  LoginUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 24/03/26.
//

import Foundation

final class LoginUseCase {
    
    private let authRepository: AuthRepositoryProtocol
    private let credentialRepository: CredentialRepositoryProtocol
    
    init(
        authRepository: AuthRepositoryProtocol,
        credentialRepository: CredentialRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.credentialRepository = credentialRepository
    }
    
    func execute(email: String, password: String) async throws -> String {
        let id =  try await authRepository.signIn(email: email, password: password)
        try credentialRepository.saveCredential(email: email, password: password)
        try await authRepository.token(username: "Michele", password: "Michele1")
        return id
    }
}
