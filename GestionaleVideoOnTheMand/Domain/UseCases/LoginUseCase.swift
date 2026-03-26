//
//  LoginUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 24/03/26.
//

import Foundation

class LoginUseCase {
    private let authRepository: AuthReposotoryProtocol
    
    init(authRepository: AuthReposotoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute(email: String, password: String) async throws -> String {
       let id =  try await authRepository.signIn(email: email, password: password)
        try await authRepository.token(username: "Michele", password: "Michele1")
        return id
    }
}
