//
//  RestorePasswordUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 30/04/26.
//

import Foundation

final class RestorePasswordUseCase {
    private var repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(email: String) async throws {
      try await repository.restorePassword(email: email)
    }
}
